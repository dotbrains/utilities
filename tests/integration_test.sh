#!/bin/bash

# Integration tests for utilities.sh
# Tests the main features: versioning, debug mode, selective loading, and caching

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

run_test() {
    ((TESTS_RUN++))
    local test_name="$1"
    shift
    
    print_test "$test_name"
    
    if "$@"; then
        print_pass "$test_name"
        return 0
    else
        print_fail "$test_name"
        return 1
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_version_constant() {
    local output
    output=$(bash -c "cd '$REPO_ROOT' && source utilities.sh && echo \$UTILITIES_VERSION" 2>/dev/null)
    
    if [[ -n "$output" ]] && [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "  Version: $output"
        return 0
    fi
    
    return 1
}

test_debug_mode() {
    local output
    output=$(bash -c "cd '$REPO_ROOT' && export UTILITIES_DEBUG=true && source utilities.sh 2>&1")
    
    if echo "$output" | grep -q "\[utilities\]"; then
        echo "  Debug output detected"
        return 0
    fi
    
    return 1
}

test_selective_loading() {
    local output
    # Only load git module
    output=$(bash -c "cd '$REPO_ROOT' && export UTILITIES_MODULES=git && export UTILITIES_DEBUG=true && source utilities.sh 2>&1")
    
    # Should load git module
    if ! echo "$output" | grep -q "modules/git/git.sh"; then
        echo "  Error: git module not loaded"
        return 1
    fi
    
    # Should NOT load homebrew module
    if echo "$output" | grep -q "modules/homebrew/brew.sh"; then
        echo "  Error: homebrew module should not be loaded"
        return 1
    fi
    
    echo "  Selective loading working correctly"
    return 0
}

test_caching() {
    local cache_dir="/tmp/utilities-test-cache-$$"
    
    # Set up cleanup trap
    trap 'rm -rf "$cache_dir"' EXIT INT TERM
    
    # Clean up any existing cache
    rm -rf "$cache_dir"
    
    # First run - should create cache
    bash -c "cd '$REPO_ROOT' && export UTILITIES_CACHE_DIR='$cache_dir' && export UTILITIES_DEBUG=true && source utilities.sh" > /dev/null 2>&1
    
    # Check cache directory was created
    if [[ ! -d "$cache_dir" ]]; then
        echo "  Error: cache directory not created"
        rm -rf "$cache_dir"
        return 1
    fi
    
    # Check some files were cached
    if [[ ! -f "$cache_dir/base/base.sh" ]]; then
        echo "  Error: base.sh not cached"
        rm -rf "$cache_dir"
        return 1
    fi
    
    # Second run - should use cache
    local output
    output=$(bash -c "cd '$REPO_ROOT' && export UTILITIES_CACHE_DIR='$cache_dir' && export UTILITIES_DEBUG=true && source utilities.sh 2>&1")
    
    if ! echo "$output" | grep -q "Using cached"; then
        echo "  Error: cache not being used"
        rm -rf "$cache_dir"
        return 1
    fi
    
    echo "  Cache directory: $cache_dir"
    echo "  Caching working correctly"
    
    # Cleanup and remove trap
    trap - EXIT INT TERM
    rm -rf "$cache_dir"
    return 0
}

test_base_functions_available() {
    local script='
        cd '"'$REPO_ROOT'"' && source utilities.sh 2>/dev/null
        
        # Test some base functions exist
        type cmd_exists >/dev/null 2>&1 || exit 1
        type is_macos >/dev/null 2>&1 || exit 1
        type print_success >/dev/null 2>&1 || exit 1
        
        echo "Functions available"
    '
    
    local output
    output=$(bash -c "$script")
    
    if [[ "$output" == "Functions available" ]]; then
        echo "  Base functions loaded successfully"
        return 0
    fi
    
    return 1
}

test_error_handling() {
    # Test with invalid URL (simulated by using wrong branch)
    local output
    local exit_code
    
    output=$(bash -c "
        cd '$REPO_ROOT'
        
        # Temporarily modify function to use invalid URL
        source utilities.sh 2>&1
        
        # Try to load non-existent file
        source_file_from_utilities 'nonexistent/file.sh' 2>&1
    " 2>&1) || exit_code=$?
    
    # Should handle error gracefully
    if [[ $exit_code -ne 0 ]] || echo "$output" | grep -q "ERROR"; then
        echo "  Error handling working"
        return 0
    fi
    
    return 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    echo "========================================"
    echo " Utilities.sh Integration Tests"
    echo "========================================"
    echo ""
    
    cd "$REPO_ROOT"
    
    # Run tests
    run_test "Version constant exists" test_version_constant
    run_test "Debug mode works" test_debug_mode
    run_test "Selective module loading" test_selective_loading
    run_test "Caching mechanism" test_caching
    run_test "Base functions available" test_base_functions_available
    run_test "Error handling" test_error_handling || true  # Don't fail on this one
    
    # Summary
    echo ""
    echo "========================================"
    echo " Test Summary"
    echo "========================================"
    echo "Total tests run:    $TESTS_RUN"
    echo "Tests passed:       $TESTS_PASSED"
    echo "Tests failed:       $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

main "$@"
