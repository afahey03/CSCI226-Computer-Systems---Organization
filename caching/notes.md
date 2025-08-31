Project 7 - Caching - Aidan
===========================

C++ program to simulate fully associative cache. Some description provided in
prologue, which is helpful, but not many details included (doesn't mention if
cache is fully associative or direct-mapped, for example, or cache dimensions).

Code is straightforward and clear, split into lots of useful helper functions,
with some useful comments.

Total cache size is 4 bytes per row x 4 rows? Why so small? Would it work with
other sizes?
Eviction policy: LFA (this is a nice touch!)
32-bit addresses.
Variable named cacheSize is misleadingly named, this is the cache height, not
size.

Simulates action of cache with user-interaction. User inputs addresses (in
decimal), program simulates generic byte-level access. No checking for word
alignment, etc.

Main memory and cache contents are not simulated. This is fine.
Used a few 1D arrays for metadata, with appropriate types (bool, int, etc).

Splits address using mod and division. Masking and shifting would have been
nicer here, for more realism.

For an associative cache, tag=blocknum. But your tag is calculated as
blockNum/height, which is incorrect. This will lead to over-estimation of hits.

lfaCount is initialized incorrectly during a replacement. It is set to 0, but
should be set to 1.

Tracks basic stats on hits, misses, prints these at end of program.

Prints hit and miss info on each access, though doesn't reveal details of cache
state to user. This makes it hard to verify if cache is working as intended. But
the bugs mentioned above can be seen with certain inputs, e.g.:

    Enter address or -1 to stop: 0
    Biff! Tag 0 Offset: 0
    Enter address or -1 to stop: 4
    Splash! Tag: 0 Offset: 0

These should not have the same tag, since they are different blocks. The second
access should be a miss.

# Score: 7.5/10

