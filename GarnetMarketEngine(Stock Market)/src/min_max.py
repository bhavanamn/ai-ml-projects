# function to perform Min-Max scaling with bias
def min_max_scaling_with_bias(column,column_min,column_max, bias_min=None, bias_max=None):

    # add bias to the minimum and maximum values if specified
    if bias_min is not None:
        column_min -= bias_min
    if bias_max is not None:
        column_max += bias_max

    # perform Min-Max scaling
    column_scaled = (column - column_min) / (column_max - column_min)

    return column_scaled, column_min, column_max



# function to perform inverse transformation and return the original values
def min_max_scaling_inverse(column_scaled, column_min, column_max, bias_min=None, bias_max=None):
    # remove bias from the minimum and maximum values if specified
    if bias_min is not None:
        column_min += bias_min
    if bias_max is not None:
        column_max -= bias_max

    # perform inverse transformation
    column_unscaled = column_scaled * (column_max - column_min) + column_min

    return column_unscaled
