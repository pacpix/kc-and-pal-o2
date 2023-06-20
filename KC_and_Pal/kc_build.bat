COPY kc_and_pal.asm C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Odyssey2_Dev\aswcurr\bin\kc_and_pal.asm
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Odyssey2_Dev\aswcurr\bin
asw kc_and_pal.asm
p2bin kc_and_pal.p kc_and_pal.bin -r 1024-3071
COPY kc_and_pal.bin C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Dev_Resources\o2em118win\ROMS\kc_and_pal.bin
del kc_and_pal.asm, kc_and_pal.p, kc_and_pal.bin
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Dev_Resources\o2em118win\
o2em kc_and_pal.bin -svolume=1
CD C:\Users\stach\OneDrive\Documents\Technology\Programming\Odyssey2\Odyssey2_Dev\KC_and_Pal