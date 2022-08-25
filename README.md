# Digital-lock-with-VHDL

Coding platform: Vivado2017

Development board: Nexys4 DDR FPGA Board

Functions:
  1. including 6 states(original state, user state, admin state, unlock state, alarm state, error state)
  2. The user enters the password no more than 3 times and it turns into alarm state otherwise. 
  3. The admin changes the password or shuts the alarm in admin state.
  4. The system goes back to the original state with no inkeys more than 10 sec (20 sec when unlock and admin state).
