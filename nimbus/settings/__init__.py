import os
import sys

if os.getenv("PRODUCTION", "FALSE") == "TRUE":
    from production import *
else:
    from local import *
