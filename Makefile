fftw_includedir = fftw/include
fftw_libdir = fftw/lib
BOOST_DIR = /usr/include/boost
BOOST_LIB = /usr/lib/
DEBUG_FLAGS = -ggdb
PRODUCTION_FLAGS = -O2
CPPFLAGS = -I$(fftw_includedir) -I $(BOOST_DIR)
CXXFLAGS = -Wall $(DEBUG_FLAGS)
LDFLAGS = -L$(fftw_libdir) -L$(BOOST_LIB)
FFTW3_LIBS = -lfftw3
BOOST_LIBS = -lboost_program_options
STATIC = -static-libgcc -static-libstdc++ -static
CXX=g++

OBJECT_FILES := my_utils.o

all: xcorrSound

clean:
	rm -rf *.o xcorrSound test_cross soundMatch

my_utils.o :
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c my_utils.cpp -o my_utils.o

cross_correlation : cross_correlation.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(FFTW3_LIBS) $(LDFLAGS) $(STATIC) cross_correlation_test.cpp -o cross_correlation_test 

xcorrSound.o : xcorrSound.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(STATIC) -m64 -c xcorrSound.cpp -o xcorrSound.o

logstream.o : logstream.h logstream.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c logstream.cpp -o logstream.o

xcorrSound : $(OBJECT_FILES) xcorrSound.o logstream.o
	$(CXX) $(CXXFLAGS) $(STATIC) -m64 logstream.o my_utils.o xcorrSound.o -o xcorrSound $(LDFLAGS) $(FFTW3_LIBS) 

AudioFile.o : AudioFile.h AudioFile.cpp AudioStream.h my_utils.o
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OBJECT_FILES) -c AudioFile.cpp -o AudioFile.o

soundMatch : AudioStream.h AudioFile.o sound_match.cpp my_utils.o
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OBJECT_FILES) AudioFile.o sound_match.cpp -o soundMatch $(LDFLAGS) $(FFTW3_LIBS)

test_cross : test_cross.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) test_cross.cpp -o test_cross $(LDFLAGS) $(FFTW3_LIBS)

migrationQA : migrationQA.cpp cross_correlation.h AudioFile.o my_utils.o logstream.o
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(STATIC) logstream.o my_utils.o AudioFile.o migrationQA.cpp -o migrationQA $(LDFLAGS) $(FFTW3_LIBS) $(BOOST_LIBS)

spectrum: spectrum.cpp cross_correlation.h AudioFile.o my_utils.o logstream.o
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(STATIC) logstream.o my_utils.o AudioFile.o spectrum.cpp -o spectrum $(LDFLAGS) $(FFTW3_LIBS) $(BOOST_LIBS)

.PHONY : all clean fftw