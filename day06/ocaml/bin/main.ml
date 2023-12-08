

let read_file_contents filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let contents = really_input_string chan len in
  close_in chan;
  contents


let first_argument = Sys.argv.(1)

let parse_nums s =
  s 
  |> String.trim |> String.split_on_char ' ' 
  |> List.map String.trim  |> List.filter (fun s -> s <> "")
  |> List.map int_of_string

let replace_in_string s old new_ =
  let re = Str.regexp old in
  Str.global_replace re new_ s

let parse_times s =
  replace_in_string s "Time: " "" |> parse_nums

let parse_distances s =
  replace_in_string s "Distance: " "" |> parse_nums

let zip_lists l1 l2 =
  List.map2 (fun x y -> (x, y)) l1 l2

let parse_times_and_distances s =
  let lines = String.split_on_char '\n' s in
  let times = List.nth lines 0 |> parse_times in
  let distances = List.nth lines 1 |> parse_distances in
  zip_lists times distances

let compute_distance max_time button_time =
  let running_time = max_time - button_time in
  let distance = running_time * button_time in
  (button_time, distance)

let ways_to_win max_time record_distance =
  let button_times = List.init max_time (fun x -> x) in
  button_times 
  |> List.map (compute_distance max_time)
  |> List.filter (fun (_, distance) -> distance > record_distance)
  |> List.length

let apply2 f (x, y) = f x y

let () = 
  let content = read_file_contents first_argument in
  let times_and_distances = parse_times_and_distances content in
  let wins = times_and_distances |> List.map (apply2 ways_to_win) in
  let product = List.fold_left ( * ) 1 wins in
  print_endline (string_of_int product)
