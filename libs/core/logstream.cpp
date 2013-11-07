#include "logstream.h"
#include "stdint.h"
#include <iostream>
#include <cstdio>

using namespace std;

namespace level {
    const int32_t FATAL = 1;
    const int32_t ERROR = 2;
    const int32_t INFORMATION = 3;
    const int32_t WARNING = 4;
    const int32_t DEBUG = 5;
}

/**
 * logstream buffer start
 */

logstreambuffer::logstreambuffer(int32_t _level, const char *filename) {
    setp(buf, buf+buf_sz);
    this->print_level = _level;
    logfile = fopen(filename, "a");
}

logstreambuffer::~logstreambuffer() {
    flush();
    sync();
    fclose(logfile);
}

void logstreambuffer::flush() {
    if (this->print_level >= this->level) {
	fwrite(buf, sizeof(char), pptr()-buf, logfile);
    }
    setp(buf, buf+buf_sz);
}

int logstreambuffer::overflow(int c) {
    flush();
    *pptr() = c;
    pbump(1);
    return 0;
}

int logstreambuffer::sync() {
    flush();
    return 0;
}

void logstreambuffer::set_level(int32_t level) {
    if (this->level == level) return;
    sync();
    this->level = level;
}

/**
 * logstream start
 */
void logstream::set_level(int32_t n) {
    buffer.set_level(n);
}

void logstream::set_print_level(int32_t n) {
    buffer.print_level = n;
}

/**
 * logging manipulators
 */

log_level log_debug() {
    return log_level(level::DEBUG);
}

log_level log_information() {
    return log_level(level::INFORMATION);
}

log_level log_fatal() {
    return log_level(level::FATAL);
}

log_level log_error() {
    return log_level(level::ERROR);
}

log_level log_warning() {
    return log_level(level::WARNING);
}

logstream& operator<<(logstream &ls, log_level ll) {
    ls.set_level(ll.n);
    switch (ll.n) {
    case level::DEBUG:
	ls << std::endl << " --- DEBUG --- " << std::endl;
	break;
    case level::INFORMATION:
	ls << std::endl << " --- INFORMATIONAL ---" << std::endl;
	break;
    case level::FATAL:
	ls << std::endl << " --- FATAL ---" << std::endl;
	break;
    case level::ERROR:
	ls << std::endl << " --- ERROR ---" << std::endl;
	break;
    case level::WARNING:
	ls << std::endl << " --- WARNING ---" << std::endl;
	break;
    }
    return ls;
}
