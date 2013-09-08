open BatString
open String
open Printf

type value =
    Int of int
  | String of string
  | List of value list
  | Dictionnary of (string * value) list

exception InvalidBencode

let decode str =
  let rec aux accum index =
    match get str index with
    | 'e' -> (List.rev accum, index + 1)

    | 'i' ->
      let first = index + 1 in
      let last = index_from str first 'e' in
      let int_str = slice ~first:first ~last:last str in
      aux (Int (int_of_string int_str) :: accum) (last + 1)

    | 'l' ->
      let lst, last = aux [] (index + 1) in
      aux ((List lst) :: accum) (last + 1)

    | 'd' ->
      let rec dict_of_list accum = function
          (String a) :: b :: t -> dict_of_list ((a, b) :: accum) t
        | [] -> accum
        | _ -> raise InvalidBencode in
      let lst, last = aux [] index in
      aux (Dictionnary (dict_of_list [] lst) :: accum) (last + 1)

    | '0' .. '9' ->
      let last = index_from str index ':' in
      let int_str = slice ~first:index ~last:last str in
      let str_first = last + 1 in
      let str_last = str_first + (int_of_string int_str) in
      aux (String (slice ~first:str_first ~last:str_last str) :: accum) (str_last + 1)

    | _ -> raise InvalidBencode in
  let lst, _ = aux [] 0 in
  List (List.rev lst)

