-- rl_deconv.adb
with Ada.Numerics;

package body RL_Deconvolution is

   function Convolve (Input : Matrix; Kernel : Matrix) return Matrix is
      Rows    : constant Integer := Input'Length(1);
      Cols    : constant Integer := Input'Length(2);
      K_Rows  : constant Integer := Kernel'Length(1);
      K_Cols  : constant Integer := Kernel'Length(2);
      Result  : Matrix(1 .. Rows, 1 .. Cols) := (others => (others => 0.0));
      Pad_R   : constant Integer := K_Rows / 2;
      Pad_C   : constant Integer := K_Cols / 2;
   begin
      -- Standard 2D Convolution Logic
      for R in 1 .. Rows loop
         for C in 1 .. Cols loop
            for Kr in 1 .. K_Rows loop
               for Kc in 1 .. K_Cols loop
                  declare
                     Ir : constant Integer := R + Kr - 1 - Pad_R;
                     Ic : constant Integer := C + Kc - 1 - Pad_C;
                  begin
                     if Ir in 1 .. Rows and Ic in 1 .. Cols then
                        Result(R, C) := Result(R, C) + (Input(Ir, Ic) * Kernel(Kr, Kc));
                     end if;
                  end;
               end loop;
            end loop;
         end loop;
      end loop;
      return Result;
   end Convolve;

   function Deconvolve (
      Observed   : Matrix;
      PSF        : Matrix;
      Iterations : Positive;
      Damped     : Boolean := False
   ) return Matrix is
      Rows   : constant Integer := Observed'Length(1);
      Cols   : constant Integer := Observed'Length(2);
      Est    : Matrix(1 .. Rows, 1 .. Cols) := (others => (others => 0.5)); -- Initial guess (uniform)
      PSF_F  : Matrix(1 .. PSF'Length(1), 1 .. PSF'Length(2)); -- Flipped PSF
      
      -- Helper: Flip kernel for adjoint convolution
      procedure Flip_PSF is
      begin
         for R in 1 .. PSF'Length(1) loop
            for C in 1 .. PSF'Length(2) loop
               PSF_F(R, C) := PSF(PSF'Last(1) - R + 1, PSF'Last(2) - C + 1);
            end loop;
         end loop;
      end Flip_PSF;

   begin
      if PSF'Length(1) mod 2 = 0 or PSF'Length(2) mod 2 = 0 then
         raise Invalid_Dimensions with "PSF dimensions must be odd.";
      end if;

      Flip_PSF;

      for Iter in 1 .. Iterations loop
         declare
            Blurred : constant Matrix := Convolve(Est, PSF);
            Ratio   : Matrix(1 .. Rows, 1 .. Cols);
         begin
            -- Compute Ratio (Observed / Blurred)
            for R in 1 .. Rows loop
               for C in 1 .. Cols loop
                  if Blurred(R, C) = 0.0 then
                     Ratio(R, C) := 0.0;
                  else
                     Ratio(R, C) := Observed(R, C) / Blurred(R, C);
                  end if;
               end loop;
            end loop;

            -- Apply Correction
            declare
               Correction : constant Matrix := Convolve(Ratio, PSF_F);
            begin
               for R in 1 .. Rows loop
                  for C in 1 .. Cols loop
                     Est(R, C) := Est(R, C) * Correction(R, C);
                  end loop;
               end loop;
            end;
         end;
      end loop;

      return Est;
   end Deconvolve;

end RL_Deconvolution;
