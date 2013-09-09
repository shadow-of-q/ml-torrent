open BatString

type value =
    Int of int64
  | String of string
  | List of value list
  | Dictionary of (string * value) list

exception InvalidBencode

let decode str =
  let rec aux index =
    match get str index with
    | 'i' ->
      let first = index + 1 in
      let last = index_from str first 'e' in
      let int_str = slice ~first:first ~last:last str in
      (Int (Int64.of_string int_str), last + 1)

    | 'l' ->
      let lst, last = aux_list [] (index + 1) in
      (List lst, last)

    | 'd' ->
      let rec dict_of_list accum = function
        | (String a) :: b :: t -> dict_of_list ((a, b) :: accum) t
        | [] -> accum
        | _ -> raise InvalidBencode in
      let lst, last = aux_list [] (index + 1) in
      (Dictionary (dict_of_list [] lst), last)

    | '0' .. '9'
    | '-' ->
      let last = index_from str index ':' in
      let int_str = slice ~first:index ~last:last str in
      let str_first = last + 1 in
      let str_last = str_first + (int_of_string int_str) in
      (String (slice ~first:str_first ~last:str_last str), str_last)

    | _ -> raise InvalidBencode

  and aux_list accum index =
    match get str index with
    | 'e' -> (List.rev accum, index + 1)
    | _ -> let v, last = aux index in aux_list (v :: accum) last in

  let v, _ = aux 0 in v

let encode v =
  let buf = Buffer.create 16 in
  let append_str str = Printf.bprintf buf "%d:%s" (String.length str) str in
  let rec aux = function
    | Int x -> Printf.bprintf buf "i%Lde" x
    | String str -> append_str str
    | List list ->
      Buffer.add_char buf 'l';
      List.iter aux list;
      Buffer.add_char buf 'e'
    | Dictionary list ->
      let list = List.sort (fun (a,_) (b,_) -> compare a b) list in
      Buffer.add_char buf 'd';
      List.iter (fun (str, v) -> append_str str; aux v) list;
      Buffer.add_char buf 'e' in
  aux v;
  Buffer.contents buf

