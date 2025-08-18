entity MokuGo is
    port (

        Input1 : in signed(15 downto 0);
        Input2 : in signed(15 downto 0);

        Output1 : out signed(15 downto 0);
        Output2 : out signed(15 downto 0);

        Control15 : in std_logic_vector(31 downto 0)
    );
end entity;

