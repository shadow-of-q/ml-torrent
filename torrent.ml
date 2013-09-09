open BatIO
open BatFile
open Bencode

let chan = open_in "hop.torrent"
let str = read_all chan
let decoded = Bencode.decode str
let encoded = Bencode.encode decoded;;
Printf.printf "%s" encoded

