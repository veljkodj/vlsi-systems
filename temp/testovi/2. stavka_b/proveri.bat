@rmdir /q /s work
@del /q transcript
@del /q modelsim-output.txt

@rem napravi radnu biblioteku
vlib work

@rem prevedi stavka_b_resenje.v
vlog .\stavka_b_resenje.v

@rem prevedi stavka_b_test.v
vlog .\stavka_b_test.v

@rem pokreni simulaciju modula work.stavka_b_resenje
vsim -c -do "run -all" work.stavka_b_resenje
