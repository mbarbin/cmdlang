type 'a parse = string -> ('a, [ `Msg of string ]) result
type 'a print = Format.formatter -> 'a -> unit

module Nonempty_list = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end

module Param = struct
  type 'a t =
    | Conv :
        { docv : string
        ; parse : 'a parse
        ; print : 'a print
        }
        -> 'a t
    | String : string t
    | Int : int t
    | Float : float t
    | Bool : bool t
    | File : string t
    | Enum :
        { docv : string option
        ; choices : (string * 'a) Nonempty_list.t
        }
        -> 'a t
end

module Arg = struct
  type 'a t =
    | Return : 'a -> 'a t
    | Map :
        { x : 'a t
        ; f : 'a -> 'b
        }
        -> 'b t
    | Both : 'a t * 'b t -> ('a * 'b) t
    | Apply :
        { f : ('a -> 'b) t
        ; x : 'a t
        }
        -> 'b t
    | Flag :
        { names : string Nonempty_list.t
        ; doc : string
        }
        -> bool t
    | Named :
        { names : string Nonempty_list.t
        ; doc : string
        ; docv : string option
        ; param : 'a Param.t
        }
        -> 'a t
    | Named_opt :
        { names : string Nonempty_list.t
        ; doc : string
        ; docv : string option
        ; param : 'a Param.t
        }
        -> 'a option t
    | Named_with_default :
        { names : string Nonempty_list.t
        ; doc : string
        ; docv : string option
        ; param : 'a Param.t
        ; default : 'a
        }
        -> 'a t
    | Pos :
        { doc : string option
        ; docv : string option
        ; index : int
        ; param : 'a Param.t
        }
        -> 'a t
    | Pos_opt :
        { doc : string option
        ; docv : string option
        ; index : int
        ; param : 'a Param.t
        }
        -> 'a option t
    | Pos_with_default :
        { doc : string option
        ; docv : string option
        ; index : int
        ; param : 'a Param.t
        ; default : 'a
        }
        -> 'a t
    | Pos_all :
        { doc : string option
        ; docv : string option
        ; param : 'a Param.t
        }
        -> 'a list t
end

module Command = struct
  type 'a t =
    | Make :
        { arg : 'a Arg.t
        ; summary : string
        }
        -> 'a t
    | Group :
        { default : 'a Arg.t option
        ; summary : string
        ; subcommands : (string * 'a t) list
        }
        -> 'a t
end
