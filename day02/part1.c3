import std::io;
import libc;

fn char[]! read_file(String filename) {
  File file = file::open("input.txt", 'r');
  defer file.close();

  char[] buffer;
}

fn void main(){
  io::printn("Hello world");
  return 0;
}
