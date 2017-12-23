require 'torch'
require 'nn'

local N = {}


local function init_nn(inputs, outputs)
  local net = nn.Sequential()
  net:add(nn.Linear(inputs, 200))
  net:add(nn.Tanh())
  net:add(nn.Linear(200, 500))
  net:add(nn.Tanh())
  net:add(nn.Linear(500, 900))
  net:add(nn.Tanh())
  net:add(nn.Linear(900, outputs))
  
  local criterion = nn.MSECriterion()
  return net, criterion
end


local function forward_prop(input, net, nth_best, random_percentage, override_action, outputs)
  local action = 0
  local action_table = {}
  if (override_action > 0) then
    local output = net:forward(input)
    return input, output, override_action
  else
    local output = net:forward(input)
    local max_reward = math.huge * -1
    for i=1,outputs do
      action_table[i] = {i, output[i]}
    end
    
    table.sort(action_table, function(a,b) return a[2] > b[2] end)
    
--    print("Picking the Nth best choice: " .. tostring(nth_best))      
    action = action_table[nth_best][1]
--    print("Action Predicted: " .. tostring(action))
    action = random_chance(action, action_table, random_percentage, nth_best, outputs)
--    print("Action Taken: " .. tostring(action))
    return input, output, action
  end
end


local function back_prop(input, predicted_output, actual_output, net, criterion, learning_rate)
  
  local err = criterion:forward(net:forward(input), actual_output)
  local gradOutput = criterion:backward(predicted_output, actual_output)
  net:zeroGradParameters()
  net:backward(input, gradOutput)
  net:updateParameters(learning_rate)
    
--  print("Predicted Output: " .. tostring(predicted_output))  
--  print("Actual Output: " .. tostring(actual_output))
  print("Error: \n" .. tostring(err))
--  print("Rand Chance: " ..tostring(rand_test))

end


N.init_nn = init_nn
N.forward_prop = forward_prop
N.back_prop = back_prop

return N

