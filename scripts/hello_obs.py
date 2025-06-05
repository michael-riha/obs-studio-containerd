import obspython as S
import pprint
import sys

def script_load(settings):
    # See how to secure this option if you are using it with remote.
    is_debugger_started = False
    print(f"hello OBS is loaded! with Python version {sys.version}.")
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(settings)


def script_unload():
    print("unload")