class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  private
  
  # Take the evaluation and return its mat
  def getMatrix(dim, evaluation)
    mat = Matrix.identity(dim).to_a
    evaluation.each_with_index do |src, i|
      row = src.last
      row.each_with_index do |val, j|
        mat[i][j+i+1] = val.last
        mat[j+i+1][i] = 1/Float(val.last)
      end
    end
    mat
  end 
  
  # Check the matrix consistency and return its wieghts
  def checkConsistency(mat)
    if mat.count == mat.transpose.count
      weights =  clacWeight(mat)
      if consistent?(mat, weights)
        return weights
      else
        return false
      end
    else
      I18n.t(:err_msg, :msg => (I18n.t(:mat_not_square)) )
    end
  end 

  # Calc weight of each alternative
  def clacWeight(mat)
    root = Float(mat.count)
    root_product = mat.map { |row| (row.reduce(:*))**(1/root) }
    weight  = root_product.map { |v| v/Float(root_product.reduce(:+)) }
  end
  
  # check the consistency of the matrix
  def consistent?(mat, weights)
    ri = [1, 1, 0.58, 0.9, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49, 1.51, 1.48, 1.56, 1.57, 1.59]
    n = mat.count
    sum = mat.transpose.map { |row| row.reduce(:+) }
    lambda_max = (Matrix.row_vector(sum) * Matrix.column_vector(weights)).to_a.first.first
    ci = (lambda_max - n) / Float(n - 1)
    cr = ci / ri[n-1]
    (cr < 0.1) ? true : false
  end

  
end
