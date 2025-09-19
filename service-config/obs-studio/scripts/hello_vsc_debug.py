import obspython as S
import pprint
import sys
import debugpy

def script_load(settings):
    # See how to secure this option if you are using it with remote.
    is_debugger_started = False
    print(f"hello OBS is loaded! with Python version {sys.version}.")
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(settings)
    if is_debbuger_started:
        start_remote_debugger()
        is_debbuger_started: True


def start_remote_debugger():
    debugpy.listen(('0.0.0.0', 5678)) # listen for incoming DAP client connections
    debugpy.wait_for_client()  # wait for a client to connect
    S.timer_add(timer_func, 1 * 1000)
    # debugpy.debug_this_thread()
    # debugpy.breakpoint()
    # debugpy.wait_for_client()  # blocks execution until client is attached

def timer_func():
    debugpy.breakpoint()
    print("Timer function called")
    S.timer_remove(timer_func) 

def script_unload():
    print("unload")