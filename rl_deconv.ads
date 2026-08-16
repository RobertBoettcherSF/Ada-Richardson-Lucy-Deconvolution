-- rl_deconv.ads
package RL_Deconvolution is
   -- Custom types for the algorithm
   type Matrix is array (Integer range <>, Integer range <>) of Float;
   
   -- Exceptions
   Invalid_Dimensions : exception;
   Zero_Division      : exception;

   -- Main Richardson-Lucy Deconvolution Procedure
   -- @param Observed: The blurred input image
   -- @param PSF: Point Spread Function (kernel)
   -- @param Iterations: Number of iterations to run
   -- @param Damped: If True, uses dampened variant (prevents noise amplification)
   -- @return: The restored image
   function Deconvolve (
      Observed   : Matrix;
      PSF        : Matrix;
      Iterations : Positive;
      Damped     : Boolean := False
   ) return Matrix;

   -- Helper to perform 2D convolution
   function Convolve (Input : Matrix; Kernel : Matrix) return Matrix;

end RL_Deconvolution;
