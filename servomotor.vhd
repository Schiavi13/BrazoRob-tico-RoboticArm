library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--En vez de switches, aumentar el movimiento automaticamente de 0 a 255 y luego otra vez a 0
entity servomotor is
	port ( 
		Clock 		: in  std_logic;
		Reset 		: in  std_logic;
		PW 		 	: in  std_logic_vector(7 downto 0);
		PWM	 		: out  std_logic
		
	);
end servomotor;

architecture servomotor_Arquitectura of servomotor is

signal Counter1s: std_logic_vector(9 downto 0) := (others=>'0'); --25 bits - 50 millones
		--1 s
signal enabler: std_logic := '0'; --Habilitador de 1 segundo activo
		--16 s
signal CounterTotal: std_logic_vector(11 downto 0) := (others=>'0'); --Ancho total de la se�al

signal PWInt: std_logic_vector(8 downto 0) := (others=>'0'); --Ancho total de la se�al

signal PWMSignal: std_logic := '0'; --Habilitador de 1 segundo activo

begin

-- Habilita la se�al cada segundo
process (Clock, Reset)
begin
	if (Reset = '1') then
		Counter1s <= (others=>'0');
		enabler <= '0';
   elsif rising_edge(Clock) then  
      Counter1s <= Counter1s + 1;
		enabler <= '0';
		--50 mil para motor, 50 millones para LED
		if (Counter1s >= 781) then
			Counter1s <= (others=>'0');
			enabler <= '1';
		end if;
   end if;
end process;

  
process (Clock, Reset)
begin
	if (Reset = '1') then
		CounterTotal <= (others=>'0');
   elsif rising_edge(Clock) then 
		if (enabler = '1') then
			CounterTotal <= CounterTotal + 1; --Aumenta el ancho de pulso
			if (CounterTotal >= 1280) then
				CounterTotal <= (others=>'0');
			end if;
		end if;
   end if;
end process;


process (Clock, Reset)
begin
	if (Reset = '1') then
		PWInt <= (others=>'0');
		PWMSignal <= '0';
		
   elsif rising_edge(Clock) then 
		PWInt <= '0'&(PW + 64);
		if ( CounterTotal <= ("000" & PWInt) ) then
			PWMSignal <= '1' ;
		else 
			PWMSignal <= '0';
		end if;
   end if;
end process;

PWM <= PWMSignal;


end servomotor_Arquitectura;