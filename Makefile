all: native byte

native:
	ocamlbuild -verbose 1 -use-ocamlfind -pkgs batteries torrent.native

byte:
	ocamlbuild -cflags -g -verbose 1 -use-ocamlfind -pkgs batteries torrent.byte

