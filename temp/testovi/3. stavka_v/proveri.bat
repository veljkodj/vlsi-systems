@rmdir /q /s work
@del /q transcript
@del /q modelsim-output.txt

@rem napravi radnu biblioteku
vlib work

@rem prevedi stavka_v_resenje.v
vlog .\stavka_v_resenje.v

@rem prevedi stavka_v_test.v
vlog .\stavka_v_test.v

@rem pokreni simulaciju modula work.stavka_v_test
vsim -c -do "run -all" work.stavka_v_test