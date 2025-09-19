#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directory to store log files
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Array of scripts to run (with paths relative to this script's location)
SCRIPTS=("${SCRIPT_DIR}/services/dbus-service.sh" 
         "${SCRIPT_DIR}/services/pulse-audio.sh" 
         "${SCRIPT_DIR}/services/obs-service.sh" 
         "${SCRIPT_DIR}/services/ffmpeg-service.sh")

# Function to stop all existing screen sessions and related processes
cleanup_existing_sessions() {
    echo -e "${BLUE}Cleaning up existing screen sessions...${NC}"
    
    # Find and kill all screen sessions
    if screen -ls | grep -q .; then
        screen -ls | grep -o '[0-9]\+\.[^[:space:]]\+' | while read session; do
            echo -e "${YELLOW} ⏹️    Terminating screen session: $session${NC}"
            screen -S "$session" -X quit
        done
    else
        echo -e "${GREEN}No existing screen sessions found.${NC}"
    fi
    
    # Kill any potentially lingering processes based on script names
    for script in "${SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script" .sh)
            service_name=${script_name%-service}  # Remove "-service" suffix to get base service name
            
            if pgrep -f "$service_name" > /dev/null; then
                echo -e "${YELLOW} 🛑   Stopping $service_name processes...${NC}"
                pkill -f "$service_name"
            fi
        fi
    done
    
    # Brief pause to allow processes to terminate
    sleep 1
    echo -e "${GREEN} 🧹 Cleanup complete.${NC}"
    echo -e "-------------------------------------------------------------------"
}

# Run cleanup before starting
cleanup_existing_sessions

# Function to run a script in a screen session with logging
run_in_screen() {
    local script_path=$1
    local script_name=$(basename "$script_path" .sh)  # Remove .sh extension for cleaner names
    local log_file="$LOG_DIR/${script_name}.log"
    
    # Create a screen session for this script with better error handling
    screen -dmS "$script_name" bash -c "
        # Explicit grouping for clarity
        {
            # Set up output redirection first
            exec > >(tee -a \"$log_file\") 2>&1
            
            echo \"[$(date)] Starting $script_name service...\"
            
            # Check if script exists and is executable
            if [ ! -x \"$script_path\" ]; then
                echo \"${RED}ERROR: Script $script_path is not executable! Setting permissions.${NC}\"
                chmod +x \"$script_path\"
            fi
            
            # Run the script, and if it fails, keep the screen session alive
            \"$script_path\" || { 
                echo \"${RED}ERROR: $script_name failed with exit code $?. Check the log for details.${NC}\";
                echo \"${YELLOW}Keeping screen session alive for inspection.${NC}\";
                exec bash;  # Keep the session alive with a shell
            }
        }
    "
}

# Main execution
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script" .sh)
        echo -e "${CYAN}  🚀 Starting ${NC}${GREEN}$script_name service ${NC}${CYAN}in screen session...${NC}"
        run_in_screen "$script"
        
        # Add sleep between service starts
        # Give more time to critical services
        case "$script_name" in
            "dbus-service"|"pulse-audio")
                echo -e "${BLUE}Waiting for $script_name to initialize...${NC}"
                sleep 3  # Longer delay for critical system services
                ;;
            *)
                sleep 1  # Standard delay for other services
                ;;
        esac
    else
        echo -e "${RED}Error: Script $script not found!${NC}" >&2
    fi
done

# Give the sessions a moment to initialize
sleep 1

# List all running screen sessions
echo -e "\n${GREEN}Active screen sessions:${NC}"
screen -ls

# Usage instructions
echo -e "\n------------ USAGE INSTRUCTIONS ------------------"
echo -e "${CYAN}To attach to a session:${NC}"
echo "  screen -r <session_name>   # example: screen -r obs"
echo -e "${CYAN}To detach from a session:${NC}"
echo "  Press Ctrl+A then D"
echo -e "\n${CYAN}To check logs:${NC}"
echo "  cat logs/<service_name>.log"
# Keep the container running
exec tail -f /dev/null