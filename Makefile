all: native byte

native:
	ocamlbuild -no-hygiene -verbose 1 -use-ocamlfind -pkgs str,batteries torrent.native

byte:
	ocamlbuild -no-hygiene -verbose 1 -use-ocamlfind -pkgs str,batteries torrent.byte

