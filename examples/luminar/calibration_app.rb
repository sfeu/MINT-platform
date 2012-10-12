require 'matrix'
require 'rational'

module CalibrationApp
  SCREEN_WIDTH = 640
  SCREEN_HEIGHT = 480

  @x = []
  @y = []
  @xSolution = nil
  @ySolution = nil


  def xMatrix(x,y)
    coefficients = [[x[0],y[0],x[0]*y[0],1],[x[1],y[1],x[1]*y[1],1],[x[2],y[2],x[2]*y[2],1],[x[3],y[3],x[3]*y[3],1]].collect! do |row| row.collect! { |x| Rational(x) } end
    Matrix[*coefficients]
  end

  def yMatrix(x,y)
    coefficients = [[y[0],x[0],x[0]*y[0],1],[y[1],x[1],x[1]*y[1],1],[y[2],x[2],x[2]*y[2],1],[y[3],x[3],x[3]*y[3],1]].collect! do |row| row.collect! { |x| Rational(x) } end
    Matrix[*coefficients]
  end


  def constantMy
    Matrix[[Rational(0)], [Rational(0)], [Rational(SCREEN_HEIGHT)], [Rational(SCREEN_HEIGHT)]]
  end

  def constantMx
    Matrix[[Rational(0)], [Rational(SCREEN_WIDTH)], [Rational(0)], [Rational(SCREEN_WIDTH)]]
  end

  def CalibrationApp.touch(command,fingertip)
    p "called reset #{command['name']}"
    p "fingertip #{fingertip.inspect}"

    @x[command['name'].to_i-1]= SCREEN_WIDTH-(fingertip['x'].to_i)
    @y[command['name'].to_i-1]= fingertip['y'].to_i

    if @x.length==4 and not @x.include?(nil)
      CalibrationApp.calibrate
      p "calibrated x:#{@xSolution} / y:#{@ySolution}"

      # stop calibration app and start main app
      AIContainer.first(:name=>"calibration").process_event :suspend
      AIContainer.first(:name=>"photo_app").process_event :present
    end
  end

  def CalibrationApp.is_calibrated?
    @xSolution != nil
  end

  def CalibrationApp.calibrate
    @xSolution = (xMatrix(@x,@y).inverse * constantMx).to_a.flatten
    @ySolution = (yMatrix(@x,@y).inverse * constantMy).to_a.flatten
  end

  def CalibrationApp.transform(x,y)

    return [SCREEN_WIDTH-x.to_i,y] if not CalibrationApp.is_calibrated?
    x = x.to_i
    y = y.to_i
    [(@xSolution[0]*x+@xSolution[1]*y+@xSolution[2]*x*y+@xSolution[3]).to_i,(@ySolution[0]*y+@ySolution[1]*x+@ySolution[2]*x*y+@ySolution[3]).to_i]
  end

end