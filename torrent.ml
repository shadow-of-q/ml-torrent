open BatIO
open BatFile
open Bencode

let chan = open_in "hop.torrent"
let str = read_all chan
let bencode = Bencode.decode str;;
Printf.printf "%s" str

