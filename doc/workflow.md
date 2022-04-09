1. Compile native library.
2. Generate SWIG wrappers for target language.
3. Compile and link SWIG wrappers for target language with native library.
4. Load SWIG wrappers into target language.

************************************************************************
*            $ swig -python c/example1.h
* +----------------+         +----------------------+
* |  c/example1.h  +-------->|  python/example1.c   |
* |  c/example1.c  |         |  python/example1.py  |------.
* +-----+----------+         +-+--------------------+       |
*       | $ cc -c c/example.c  | $ cc -c python/example1.c  |
*       v                      v                            |
* +----------------+         +----------------------+       |
* |  c/example1.о  |         |  python/example1.о   |       |
* +-----+----------+         +--------+-------------+       |
*       |                             |                     |
*       +----------------------------'                      |
*       | $ cc -dynamiclib -о python/_example1.so \         |
*       |    c/example1.о \                                 |
*       |    python/example1.о                              |
*       v                                                   |
* +----------------------+                                  |
* |  python/example1.sо  |                                  |
* +-----+----------------+                                  |
*       | $ python -m python/example1.py scripy.py          |
*       v                                                   |
* +----------------------+                                  |
* |  script.py           |<--------------------------------'
* +----------------------+
*
************************************************************************
