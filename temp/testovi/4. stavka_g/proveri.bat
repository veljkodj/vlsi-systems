@rmdir /q /s work
@del /q transcript
@del /q modelsim-output.txt

@rem napravi radnu biblioteku
vlib work

@rem prevedi stavka_g_resenje.v
vlog .\stavka_g_resenje.v

@rem prevedi stavka_g_test.v
vlog .\stavka_g_test.v

@rem pokreni simulaciju modula work.stavka_g_resenje
vsim -c -do "run -all" work.stavka_g_resenje
