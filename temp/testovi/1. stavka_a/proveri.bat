@rmdir /q /s work
@del /q transcript
@del /q modelsim-output.txt

@rem napravi radnu biblioteku
vlib work

@rem prevedi stavka_a_resenje.v
vlog .\stavka_a_resenje.v

@rem prevedi stavka_a_test.v
vlog .\stavka_a_test.v

@rem pokreni simulaciju modula work.stavka_a_test
vsim -c -do "run -all" work.stavka_a_test
