(*********************************************************************************)
(*                OCaml-R                                                        *)
(*                                                                               *)
(*    Copyright (C) 2008-2009 Institut National de Recherche en                  *)
(*    Informatique et en Automatique. All rights reserved.                       *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU General Public License as                    *)
(*    published by the Free Software Foundation; either version 3 of the         *)
(*    License, or  any later version.                                            *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *)
(*    GNU Library General Public License for more details.                       *)
(*                                                                               *)
(*    You should have received a copy of the GNU General Public                  *)
(*    License along with this program; if not, write to the Free Software        *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*                                                                               *)
(*********************************************************************************)

(* This is the end of the Standard module, constructed via r.ml.part1 and .part2. *)
end


(* Functions to initialise and terminate the R interpreter. *)

external init_r : string array -> int -> int = "init_r"
external terminate : unit -> unit = "end_r"

exception Initialisation_failed

let init ?(name    = try Sys.argv.(0) with _ -> "OCaml-R")
         ?(argv    = try List.tl (Array.to_list Sys.argv) with _ -> [])
         ?(env     = Standard.env)
         ?(sigs    = Standard.signal_handlers) () =
  List.iter (function name, value -> Unix.putenv name value) env;
  let r_sigs = match sigs with true -> 0 | false -> 1 in
  match init_r (Array.of_list (name::argv)) r_sigs with
  | 1 -> () | _ -> raise Initialisation_failed


(* Static types for R values. *)

module Raw0 = struct
  type sexp
end include Raw0

type langsxp (* We should perhaps make sexp a polymorphic type? *)

type t = Sexp of sexp | NULL



(* R constants - global symbols in libR.so. *)

external null_creator : unit -> sexp = "r_null"
let null = NULL



(* Conversion of R types from OCaml side to R side. *)

external null_creator : unit -> sexp = "r_null"

module Raw1 = struct
  let sexp_of_t = function
    | Sexp s -> s
    | NULL -> null_creator ()
end include Raw1



(* Runtime types internal to R. *)

module Raw2 = struct
  type internally =
    | NilSxp
    | SymSxp
    | ListSxp
    | ClosSxp
    | EnvSxp
    | PromSxp
    | LangSxp
    | SpecialSxp
    | BuiltinSxp
    | CharSxp
    | LglSxp
    | IntSxp
    | RealSxp
    | CplxSxp
    | StrSxp
    | DotSxp
    | AnySxp
    | VecSxp
    | ExprSxp
    | BcodeSxp
    | ExtptrSxp
    | WeakrefSxp
    | RawSxp
    | S4Sxp
    | FunSxp
end include Raw2

external sexptype_of_sexp : sexp -> int = "r_sexptype_of_sexp"
module Raw3 = struct
  let sexptype s = match (sexptype_of_sexp s) with
    | 0  -> NilSxp
    | 1  -> SymSxp
    | 2  -> ListSxp
    | 3  -> ClosSxp
    | 4  -> EnvSxp
    | 5  -> PromSxp
    | 6  -> LangSxp
    | 7  -> SpecialSxp
    | 8  -> BuiltinSxp
    | 9  -> CharSxp
    | 10 -> LglSxp
    (* Integer range is not defined here. *)
    | 13 -> IntSxp
    | 14 -> RealSxp
    | 15 -> CplxSxp
    | 16 -> StrSxp
    | 17 -> DotSxp
    | 18 -> AnySxp
    | 19 -> VecSxp
    | 20 -> ExprSxp
    | 21 -> BcodeSxp
    | 22 -> ExtptrSxp
    | 23 -> WeakrefSxp
    | 24 -> RawSxp
    | 25 -> S4Sxp
    (* 99 represents a 'dummy' type for functions, with is an
       umbrella for Closure, Builtin or Special types. *)
    | 99 -> FunSxp
    | _ -> failwith "R value with type not specified in Rinternals.h"
end include Raw3



(* Conversion of R types from R side to OCaml side. *)

let t_of_sexp s = match sexptype s with
  | NilSxp -> NULL
  | _ -> Sexp s



(* Beta-reduction in R. *)

external langsxp_of_list : sexp list -> int -> langsxp = "r_langsxp_of_list"
external eval_langsxp : langsxp -> sexp = "r_eval_langsxp"

let eval l =
  let sexps, n = (List.map sexp_of_t l), (List.length l) in
  let langsxp = langsxp_of_list sexps n in
  t_of_sexp (eval_langsxp langsxp)



(* Dealing with the R symbol table. *)

type symbol = string

external sexp_of_symbol : symbol -> sexp = "r_sexp_of_symbol"

let symbol (sym : symbol) = t_of_sexp (sexp_of_symbol sym)




type arg = [
    `Named of symbol * sexp
  | `Anon of sexp
  ]

external sexp : string -> sexp = "r_sexp_of_string"
external set_var : symbol -> sexp -> unit = "r_set_var"
external print : sexp -> unit = "r_print_value"

(*external exec : string -> arg array -> unit = "r_exec"
  Commented out because of C warning. Will uncoment when OCaml-R compiles on 64 bits. *)

external to_bool : sexp -> bool = "bool_of_sexp"
external to_int : sexp -> int = "int_of_sexp"
external to_float : sexp -> float = "float_of_sexp"
external to_string : sexp -> string = "string_of_sexp"

external of_bool : bool -> sexp = "sexp_of_bool"
external of_int : int -> sexp = "sexp_of_int"
external of_float : float -> sexp = "sexp_of_float"
external of_string : string -> sexp = "sexp_of_string"

(*external to_bool_array : sexp -> bool array = "bool_array_of_sexp"
  Commented out while working on 64 bits compilation. *)
(*external to_int_array : sexp -> int array = "int_array_of_sexp"
  Commented out while working on 64 bits compilation. *)
external to_float_array : sexp -> float array = "float_array_of_sexp"
(*external to_string_array : sexp -> string array = "string_array_of_sexp"
  Commented out while working on 64 bits compilation. *)

external of_bool_array : bool array -> sexp = "sexp_of_bool_array"
external of_int_array : int array -> sexp = "sexp_of_int_array"
external of_float_array : float array -> sexp = "sexp_of_float_array"
external of_string_array : string array -> sexp = "sexp_of_string_array"

external get_attrib : sexp -> string -> sexp = "r_get_attrib"

(*let dim sexp = to_int_array (get_attrib sexp "dim");;
  Commented out while working on 64 bits compilation. *)
(*let dimnames sexp = to_string_array (get_attrib sexp "dimnames");;
  Commented out while working on 64 bits compilation. *)

(*
external to_matrix : (sexp -> 'a) -> sexp -> 'a array array = "to_matrix"
external of_matrix : ('a -> sexp) -> 'a array array -> sexp = "of_matrix"


let to_bool_matrix = to_matrix to_bool;;
let to_int_matrix = to_matrix to_int;;
let to_float_matrix = to_matrix to_float;;
let to_string_matrix = to_matrix to_string;;

let of_bool_matrix = of_matrix of_bool;;
let of_int_matrix = of_matrix of_int;;
let of_float_matrix = of_matrix of_float;;
let of_string_matrix = of_matrix of_string;;
*)

module type LibraryDescription = sig
  val name : string
  val symbols : string list
end

module type Library = sig
  val root : t list 
end

module type Interpreter = sig
  module Require : functor (L : LibraryDescription) -> Library
end

module Interpreter (Env : Environment) : Interpreter = struct

  let () = init ~name: Env.name
                ~argv: Env.options
                ~env:  Env.env
                ~sigs: Env.signal_handlers
                ()

  module Require (Lib : LibraryDescription) : Library = struct
    let () = ignore (sexp ("require("^Lib.name^")"))
    let root = List.map symbol Lib.symbols
  end

end


(* Raw functions module. The purpose of this module is the help
   people dealing with the internals of the R module. It should
   not be used in the scope of vanilla R / OCaml code. *)

module Raw = struct
  include Raw0
  include Raw1
  include Raw2
  include Raw3
end

module rec Internal : sig

  module Sxp : sig

    type prom = {value: t; expr: t; env: t}

  end

  type t_content =
    | PromSxp of Sxp.prom
    | Unknown

  type t = {
    (* sxpinfo : sxpinfo; *)
    (* attrib  : t; *)
    (* gengc_nextnode : t; *)
    (* gengc_prevnode : t; *)
    content : t_content
  }

  val t_of_sexp : sexp -> t

end = struct

  (* Type definitions. *)

  module Sxp = struct

    type prom = {
      value : Internal.t;
      expr  : Internal.t;
      env   : Internal.t
    }

  end

  type t_content =
    | PromSxp of Sxp.prom
    | Unknown
  
  type t = {
    (* sxpinfo : sxpinfo; *)
    (* attrib  : Internal.t; *)
    (* gengc_nextnode : Internal.t; *)
    (* gengc_prevnode : Internal.t; *)
    content : t_content
  }

  (* Conversion functions. *)

  external inspect_promsxp_value : sexp -> sexp = "inspect_promsxp_value"
  external inspect_promsxp_expr  : sexp -> sexp = "inspect_promsxp_expr"
  external inspect_promsxp_env   : sexp -> sexp = "inspect_promsxp_env"

  let rec t_of_sexp s =
  { content = match sexptype s with
    | Raw.PromSxp -> PromSxp {
        value = t_of_sexp (inspect_promsxp_value s);
        expr  = t_of_sexp (inspect_promsxp_expr  s);
        env   = t_of_sexp (inspect_promsxp_env   s)}
    | _ -> Unknown
  }

end
