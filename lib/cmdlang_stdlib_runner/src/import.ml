module Array = struct
  include Array

  (* [Array.find_mapi] available only since 5.1 *)
  let find_mapi f t =
    let t = mapi (fun i a -> i, a) t in
    find_map (fun (i, a) -> f i a) t
  ;;
end
