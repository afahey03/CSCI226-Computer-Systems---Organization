// Aidan Fahey
// CSCI 226
// Professor Walsh
// 12/5/23
// When run: Provide an integer address (for whatever reason it doesn't work with more than 10 integers),
//           and the program will tell you whether or not your address was a hit or a miss depending on if it was already in the cache or not.
//           Displays stats at the end of the program regarding how many hits and misses, as well as the rate of both.
//           In this particular program, the cache and data memory don't actually exist, the program just tells you if it would have been a hit or a miss if they did exist.

#include <iostream>
#include <vector>
using namespace std;

const int cacheSize = 4, blockSize = 4;
double hitCount = 0, missCount = 0;

vector<int> addressTags(cacheSize, -1); // holds tags
vector<bool> validBits(cacheSize, false); // holds the valid bits
vector<int> lfaCount(cacheSize, 0); // keeps track of how recently used the addresses are

void split(int address, int& blockNum, int& tag, int& offset) { // splits the address into the block number, tag, and offset
    offset = address % blockSize;
    blockNum = address / blockSize;
    tag = blockNum / cacheSize;
}

bool hit(int tag) { // checks if address is in cache
    for (int i = 0; i < cacheSize; i++) { 
        if (validBits[i] && addressTags[i] == tag) {
            lfaCount[i]++;
            return true;
        }
    }
    return false;
}

int LFAIndex() { // calculates the least frequently used address in the cache
    int mindex = 0; // minimum + index (i find this funny)
    for (int i = 0; i < cacheSize; i++) {
        if (lfaCount[i] < lfaCount[mindex]) {
            mindex = i;
        }
    }
    return mindex;
}

void replace(int index, int tag) { // puts the address in the cache
    addressTags[index] = tag;
    validBits[index] = true;
    lfaCount[index] = 0;
}

void checkCache(int address) { // does everything
    int blockNum, tag, offset;
    split(address, blockNum, tag, offset);

    if (hit(tag)) {
        cout << "Splash! Tag: " << tag << " Offset: " << offset << "\n";
        hitCount++;
    } else {
        cout << "Biff! Tag " << tag << " Offset: " << offset << "\n";
        missCount++;
        int replaceIndex = LFAIndex();
        replace(LFAIndex(), tag);
    }
}

void showStats() { // stats
    cout << "Total Splashes: " << hitCount << "\n" << "Total Biffs: " << missCount << "\n";
    cout << "Splash Rate: " << (hitCount / (hitCount + missCount) * 100) << " %" << "\n" << "Biff Rate: " << (missCount / (hitCount + missCount) * 100) << " %" << "\n";
}

int main() { // golly gee willikers
    while (true) {
        int address, data;
        cout << "Enter address or -1 to stop: ";
        cin >> address;
        if (address == -1) break;
        checkCache(address);
    }
    showStats();
}