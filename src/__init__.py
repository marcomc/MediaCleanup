"""MediaCleanup package."""
try:
    from .mediacleanup import SCRIPT_VERSION as __version__
except ImportError:  # pragma: no cover
    __version__ = "2.1.0"

__all__ = ["__version__"]
