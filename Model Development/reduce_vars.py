def reduce_variables(model_object,classifier_name,corr_limit=0.7,data_name='train'):
    ''' Produces an optimized variable list based on a classifier variable importance and variable correlation. Choosing a list of un-corrlated variables with an importance priority. Returns a list of variable names. '''
    from copy import deepcopy

    mod = deepcopy(model_object)

    # adding variable importance 
    mod.add_variable_importance(data_name,classifier_name)
    # removing variables with an importance of 0
    drop_vars = mod.variable_importance[classifier_name]['Name'].loc[mod.variable_importance[classifier_name]['Importance'] == 0]
    drop_vars = list(drop_vars)
    # drop_vars 
    if type(mod.data[data_name]) == tuple:
        mod.data[data_name][0].drop(columns=drop_vars,inplace=True)
    else:
        mod.data[data_name].drop(columns=drop_vars,inplace=True)

    # Correlation
    mod.add_correlation(data_name)
    corr = mod.correlations[data_name]['pearson'].stack().reset_index()
    corr.columns = ['var1','var2','corr']
    # creating an abs corr value column 
    corr['abs_corr'] = abs(corr['corr'])
    
    # looping and creting a keep list
    vars_to_keep = []
    important_vars = mod.variable_importance[classifier_name].loc[mod.variable_importance[classifier_name]['Importance'] != 0]

    while True:
        if len(important_vars['Name']) == 0:
            print('All variables accounted for')
            break
        else:
            important_vars = important_vars.sort_values(by='Importance',ascending=False)
            important_vars.reset_index(inplace=True)
            important_vars.drop(columns='index',inplace=True)
            most_important_var_loop = important_vars.iloc[0][0] # taking first var from the top
            vars_to_keep.append(most_important_var_loop)
            exclude_vars = list(corr['var2'].loc[(corr['var1'] == most_important_var_loop)&(corr['abs_corr'] >= corr_limit)])
            important_vars = important_vars.loc[~important_vars['Name'].isin(exclude_vars)]

    return vars_to_keep