#!/usr/bin/python

import sys

encoded_str1 = "_z2C$q"
encoded_str2 = "_z&e3B"
encoded_str3 = "AzdH3F"

hash_table = {
  encoded_str1 : ":",
  encoded_str2 : ".",
  encoded_str3 : "/",
  "w" : "a",
  "k" : "b",
  "v" : "c",
  "1" : "d",
  "j" : "e",
  "u" : "f",
  "2" : "g",
  "i" : "h",
  "t" : "i",
  "3" : "j",
  "h" : "k",
  "s" : "l",
  "4" : "m",
  "g" : "n",
  "5" : "o",
  "r" : "p",
  "q" : "q",
  "6" : "r",
  "f" : "s",
  "p" : "t",
  "7" : "u",
  "e" : "v",
  "o" : "w",
  "8" : "1",
  "d" : "2",
  "n" : "3",
  "9" : "4",
  "c" : "5",
  "m" : "6",
  "0" : "7",
  "b" : "8",
  "l" : "9",
  "a" : "0",
}

def decode_obj_url(obj_url):
  i = 0;
  decoded_url = "";
  while i < len(obj_url):
    if (obj_url[i] == "_" and
        obj_url.find(encoded_str1, i, i + len(encoded_str1)) != -1):
      decoded_url += hash_table[encoded_str1]
      i += len(encoded_str1)
    elif (obj_url[i] == "_" and
          obj_url.find(encoded_str2, i, i + len(encoded_str2)) != -1):
      decoded_url += hash_table[encoded_str2]
      i += len(encoded_str2)
    elif (obj_url[i] == "A" and
          obj_url.find(encoded_str3, i, i + len(encoded_str3)) != -1):
      decoded_url += hash_table[encoded_str3]
      i += len(encoded_str3)
    elif obj_url[i] in hash_table:
      decoded_url += hash_table[obj_url[i]]
      i += 1
    else:
      decoded_url += obj_url[i]
      i += 1
  # print "decoded_url = ", decoded_url
  return decoded_url

def process_raw_obj_file(in_f, out_f):
  with open(in_f, 'r') as infile:
    with open(out_f, 'w') as outfile:
      for obj_url in infile:
        decoded_url = decode_obj_url(obj_url)
        outfile.write(decoded_url);

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print "Usage: ./decode.py <raw_objURL_file> <decoded_objURL_file>"
    sys.exit(1)
  infile = sys.argv[1]
  outfile = sys.argv[2]
  process_raw_obj_file(infile, outfile)