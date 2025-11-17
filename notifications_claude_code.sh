#!/bin/bash
#
# notifications_claude_code.sh - macOS Notification System for Claude Code
#
# A comprehensive notification script that integrates with macOS Notification Center
# Notifications sync across iPhone, iPad, and MacBook via iCloud
#
# Author: Claude Code Assistant
# Version: 1.0.0
# License: MIT
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="claude-notify"
readonly SCRIPT_VERSION="1.0.0"
readonly DEFAULT_TITLE="Claude Code"
readonly DEFAULT_SUBTITLE=""
readonly DEFAULT_SOUND="default"
readonly LOG_FILE="${HOME}/.claude_notifications.log"

# Notification types
readonly TYPE_INFO="info"
readonly TYPE_SUCCESS="success"
readonly TYPE_WARNING="warning"
readonly TYPE_ERROR="error"
readonly TYPE_IMPORTANT="important"

# ============================================================================
# COLORS FOR TERMINAL OUTPUT
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_info() {
    echo -e "${BLUE}9${NC} $1"
}

print_success() {
    echo -e "${GREEN}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW} ${NC} $1"
}

print_error() {
    echo -e "${RED}${NC} $1" >&2
}

log_notification() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

show_version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

show_help() {
    cat << EOF
${CYAN}$SCRIPT_NAME${NC} - macOS Notification System for Claude Code

${YELLOW}USAGE:${NC}
    $SCRIPT_NAME [OPTIONS] <message>
    $SCRIPT_NAME --type <type> <message>

${YELLOW}OPTIONS:${NC}
    -h, --help              Show this help message
    -v, --version           Show version information
    -t, --title <title>     Set notification title (default: "Claude Code")
    -s, --subtitle <text>   Set notification subtitle
    -T, --type <type>       Set notification type (info, success, warning, error, important)
    -S, --sound <sound>     Set notification sound (default, Basso, Blow, Bottle, etc.)
    -i, --important         Mark as important/critical notification
    -r, --summary           Add to notification summary (Time Sensitive)
    -q, --quiet             Don't show terminal output
    -l, --log               Log notification to file
    --no-sound              Disable notification sound
    --list-sounds           List available notification sounds

${YELLOW}NOTIFICATION TYPES:${NC}
    ${BLUE}info${NC}        Informational notification (blue icon)
    ${GREEN}success${NC}     Success notification (green checkmark)
    ${YELLOW}warning${NC}     Warning notification (yellow alert)
    ${RED}error${NC}       Error notification (red X)
    ${PURPLE}important${NC}   Critical/Important notification (purple exclamation)

${YELLOW}EXAMPLES:${NC}
    # Simple notification
    $SCRIPT_NAME "Build completed successfully"

    # Success notification with custom title
    $SCRIPT_NAME -t "Build Status" -T success "All tests passed!"

    # Important notification (Time Sensitive)
    $SCRIPT_NAME -i "Critical: Database migration required"

    # Error notification with subtitle
    $SCRIPT_NAME -T error -s "Line 42" "Syntax error in main.js"

    # Notification with custom sound
    $SCRIPT_NAME -S Glass "Deployment finished"

    # Summary notification
    $SCRIPT_NAME -r "Task completed: Refactoring done"

    # Silent notification (no terminal output)
    $SCRIPT_NAME -q "Background task finished"

    # Log notification
    $SCRIPT_NAME -l "Important: Config updated"

${YELLOW}USE WITH CLAUDE CODE:${NC}
    # After a build
    npm run build && $SCRIPT_NAME -T success "Build successful" || $SCRIPT_NAME -T error "Build failed"

    # After tests
    npm test && $SCRIPT_NAME "Tests passed " || $SCRIPT_NAME -i "Tests failed!"

    # After git operations
    git push && $SCRIPT_NAME -T success "Code pushed to remote"

${YELLOW}INTEGRATION:${NC}
    Notifications are sent to macOS Notification Center and sync across:
    - MacBook
    - iPhone (via iCloud)
    - iPad (via iCloud)

    Ensure "Allow Notifications" is enabled for Terminal/iTerm in:
    System Preferences > Notifications & Focus

EOF
}

list_sounds() {
    echo -e "${CYAN}Available notification sounds:${NC}"
    echo ""
    local sounds_dir="/System/Library/Sounds"
    if [[ -d "$sounds_dir" ]]; then
        for sound in "$sounds_dir"/*.aiff; do
            if [[ -f "$sound" ]]; then
                basename "$sound" .aiff
            fi
        done
    fi
    echo ""
    echo -e "${YELLOW}Use with:${NC} $SCRIPT_NAME -S <sound_name> <message>"
}

# ============================================================================
# NOTIFICATION FUNCTIONS
# ============================================================================

get_type_emoji() {
    local type="$1"
    case "$type" in
        "$TYPE_INFO")      echo "9" ;;
        "$TYPE_SUCCESS")   echo "" ;;
        "$TYPE_WARNING")   echo " " ;;
        "$TYPE_ERROR")     echo "L" ;;
        "$TYPE_IMPORTANT") echo "=4" ;;
        *)                 echo "=" ;;
    esac
}

get_type_prefix() {
    local type="$1"
    case "$type" in
        "$TYPE_INFO")      echo "[INFO]" ;;
        "$TYPE_SUCCESS")   echo "[SUCCESS]" ;;
        "$TYPE_WARNING")   echo "[WARNING]" ;;
        "$TYPE_ERROR")     echo "[ERROR]" ;;
        "$TYPE_IMPORTANT") echo "[IMPORTANT]" ;;
        *)                 echo "" ;;
    esac
}

send_notification() {
    local title="$1"
    local subtitle="$2"
    local message="$3"
    local sound="$4"
    local notification_type="$5"
    local is_important="$6"
    local is_summary="$7"

    # Build the AppleScript command
    local script=""

    # Add emoji prefix to message based on type
    local emoji
    emoji=$(get_type_emoji "$notification_type")
    local formatted_message="${emoji} ${message}"

    # Start building the notification script
    script="display notification \"${formatted_message}\""

    # Add title
    script="$script with title \"${title}\""

    # Add subtitle if provided
    if [[ -n "$subtitle" ]]; then
        script="$script subtitle \"${subtitle}\""
    fi

    # Add sound if not disabled
    if [[ "$sound" != "none" ]]; then
        script="$script sound name \"${sound}\""
    fi

    # Execute the notification
    osascript -e "$script" 2>/dev/null

    # For important/time-sensitive notifications, we can also trigger
    # a more persistent notification using terminal-notifier if available
    if [[ "$is_important" == "true" ]] && command -v terminal-notifier &> /dev/null; then
        terminal-notifier \
            -title "$title" \
            -subtitle "$subtitle" \
            -message "$formatted_message" \
            -sound "$sound" \
            -ignoreDnD \
            2>/dev/null || true
    fi

    return 0
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    local title="$DEFAULT_TITLE"
    local subtitle="$DEFAULT_SUBTITLE"
    local sound="$DEFAULT_SOUND"
    local notification_type="$TYPE_INFO"
    local is_important="false"
    local is_summary="false"
    local quiet="false"
    local log_enabled="false"
    local message=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -t|--title)
                if [[ -z "${2:-}" ]]; then
                    print_error "Title argument requires a value"
                    exit 1
                fi
                title="$2"
                shift 2
                ;;
            -s|--subtitle)
                if [[ -z "${2:-}" ]]; then
                    print_error "Subtitle argument requires a value"
                    exit 1
                fi
                subtitle="$2"
                shift 2
                ;;
            -T|--type)
                if [[ -z "${2:-}" ]]; then
                    print_error "Type argument requires a value"
                    exit 1
                fi
                notification_type="$2"
                shift 2
                ;;
            -S|--sound)
                if [[ -z "${2:-}" ]]; then
                    print_error "Sound argument requires a value"
                    exit 1
                fi
                sound="$2"
                shift 2
                ;;
            -i|--important)
                is_important="true"
                notification_type="$TYPE_IMPORTANT"
                shift
                ;;
            -r|--summary)
                is_summary="true"
                shift
                ;;
            -q|--quiet)
                quiet="true"
                shift
                ;;
            -l|--log)
                log_enabled="true"
                shift
                ;;
            --no-sound)
                sound="none"
                shift
                ;;
            --list-sounds)
                list_sounds
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                echo "Use '$SCRIPT_NAME --help' for usage information"
                exit 1
                ;;
            *)
                # Collect remaining arguments as message
                message="$*"
                break
                ;;
        esac
    done

    # Validate message
    if [[ -z "$message" ]]; then
        print_error "No message provided"
        echo "Use '$SCRIPT_NAME --help' for usage information"
        exit 1
    fi

    # Validate notification type
    case "$notification_type" in
        "$TYPE_INFO"|"$TYPE_SUCCESS"|"$TYPE_WARNING"|"$TYPE_ERROR"|"$TYPE_IMPORTANT")
            ;;
        *)
            print_warning "Unknown notification type '$notification_type', using 'info'"
            notification_type="$TYPE_INFO"
            ;;
    esac

    # Send notification
    if send_notification "$title" "$subtitle" "$message" "$sound" "$notification_type" "$is_important" "$is_summary"; then
        if [[ "$quiet" != "true" ]]; then
            local type_prefix
            type_prefix=$(get_type_prefix "$notification_type")

            case "$notification_type" in
                "$TYPE_SUCCESS")
                    print_success "Notification sent: $type_prefix $message"
                    ;;
                "$TYPE_WARNING")
                    print_warning "Notification sent: $type_prefix $message"
                    ;;
                "$TYPE_ERROR")
                    print_error "Notification sent: $type_prefix $message"
                    ;;
                "$TYPE_IMPORTANT")
                    echo -e "${PURPLE}!${NC} Notification sent: $type_prefix $message"
                    ;;
                *)
                    print_info "Notification sent: $type_prefix $message"
                    ;;
            esac
        fi

        # Log if enabled
        if [[ "$log_enabled" == "true" ]]; then
            local type_prefix
            type_prefix=$(get_type_prefix "$notification_type")
            log_notification "$type_prefix Title: $title | Subtitle: $subtitle | Message: $message"
            if [[ "$quiet" != "true" ]]; then
                print_info "Logged to $LOG_FILE"
            fi
        fi
    else
        print_error "Failed to send notification"
        exit 1
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script only works on macOS"
    exit 1
fi

# Run main function
main "$@"
