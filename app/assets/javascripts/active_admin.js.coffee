#= require arctic_admin/base
#= require jquery.chosen
#= require redactor-rails/redactor
#= require redactor-rails/config
#= require redactor-rails/langs/zh_cn
#= require redactor-rails/plugins

# window.EventForm =
#   hideAll: () ->
#     this.hideHBInputs()
#     this.hideRuleInputs()
#     this.hideRedbagInputs()
#     this.hideRedbagInputs2()
#     this.hideShareRedbagInputs()
#     this.hideCashRedbagConfigInputs()
#     this.hideRedbagPrizesInputs()
#
#   hideShareRedbagInputs: () ->
#     $('#event-rule-inputs').hide()
#     $('#redbag-share-inputs').hide()
#     $('#options-inputs').hide()
#   showShareRedbagInputs: () ->
#     $('#event-rule-inputs').show()
#     $('#redbag-share-inputs').show()
#     $('#options-inputs').show()
#
#   hideRedbagInputs: () ->
#     $('#redbag_f_total_input').hide()
#     $('#redbag_f_total_money_input').hide()
#     $('#redbag_f_min_value_input').hide()
#     $('#redbag_f_max_value_input').hide()
#     $('#redbag_f_value_input').hide()
#   hideRedbagInputs2: () ->
#     $('#redbag_redbag_f_total_input').hide()
#     $('#redbag_redbag_f_total_money_input').hide()
#     $('#redbag_redbag_f_min_value_input').hide()
#     $('#redbag_redbag_f_max_value_input').hide()
#     $('#redbag_redbag_f_value_input').hide()
#   hideCashRedbagConfigInputs: () ->
#     $('#wechat-redbag-configs').hide()
#   hideRedbagPrizesInputs: () ->
#     $('#redbag-prizes-inputs').hide()
#
#   hideHBInputs: () ->
#     $('#hongbao_num_input').hide()
#     $('#hongbao_total_money_input').hide()
#     $('#hongbao_min_value_input').hide()
#     $('#hongbao_max_value_input').hide()
#     $('#hongbao_value_input').hide()
#   hideRuleInputs: () ->
#     $('#quiz-rule').hide()
#     $('#checkin-rule').hide()

window.Partin = 
  showShareConfig: (yesOrNo) ->
    if yesOrNo
      $('#partin-share-configs').show()
    else
      $('#partin-share-configs').hide()
      
  toggleShareConfig: (el) ->
    $el = $(el)
    Partin.showShareConfig($el.prop('checked'))

window.Redpack = 
  showCashHBConfig: (yesOrNo) ->
    if yesOrNo
      $('#redpack-send-configs').show()
    else
      $('#redpack-send-configs').hide()
      
  toggleCashHB: (el) ->
    $el = $(el)
    Redpack.showCashHBConfig($el.prop('checked'))
  
  changeType: (el) ->
    $el = $(el)
    val = $el.val()
    money = $el.data('total-money')
    count = $el.data('total-count')
    # alert(money)
    if val == '0'
      $('#redpack_money_input .label').text('总金额')
      if money
        $('#redpack_money').val(money / 100.0)
    else
      $('#redpack_money_input .label').text('单个金额')
      if count && money
        $('#redpack_money').val(money / count / 100.0)
    
    # alert($(el).data('total_money'))

window.Redbag =
  needEventContents: () ->
    return true
  # 广告红包或任务红包输入内容显示隐藏控制
  showEventInputs: (yesOrNo) ->
    if !yesOrNo
      $('#redbag-rule-inputs').hide()      # 红包规则隐藏
      $('#redbag-share-inputs').hide()     # 红包分享隐藏
      $('#redbag-options-inputs').hide()   # 红包可选信息隐藏
      $('#redbag_win_score_input').hide()  # 红包自身概率值隐藏
      $('#redbag-prizes-inputs').hide()    # 红包奖项隐藏
    else
      $('#redbag-rule-inputs').show()   
      $('#redbag-share-inputs').show()  
      $('#redbag-options-inputs').show()
      $('#redbag_win_score_input').show() 
      $('#redbag-prizes-inputs').show()
  # 红包类型切换
  toggleRedbagType: (type) ->
    if type == '0' # 随机红包
      $('#redbag_f_total_money_input').show()
      $('#redbag_f_min_value_input').show()
      $('#redbag_f_max_value_input').show()
      $('#redbag_f_value_input').hide()
      $('#redbag_f_total_input').hide()
    else if type == '1' # 固定红包
      $('#redbag_f_value_input').show()
      $('#redbag_f_total_input').show()
      $('#redbag_f_total_money_input').hide()
      $('#redbag_f_min_value_input').hide()
      $('#redbag_f_max_value_input').hide()
  
  # 显示现金红包配置
  showCashRedbagConfigs: (yesOrNo) ->
    if yesOrNo
      $('#wechat-redbag-configs').show()
    else
      $('#wechat-redbag-configs').hide()

$(document).ready ->
  
  $("select").chosen({"search_contains": true, "no_results_text":"没有找到", "placeholder_text_single":"--请选择--"});

  Redbag.showEventInputs(true)
  
  Redpack.showCashHBConfig($('#redpack-send-configs').data('is-cash') == 1)
  
  Partin.showShareConfig($('#partin-share-configs').data('need-share') == 1)
  
  $('#redbag_use_type').change -> 
    type = $(this).val()
    if type == '2' || type == '3' || type == '6' # 非广告红包和任务红包
      Redbag.showEventInputs(false)
      if type == '6' # 现金红包
        Redbag.showCashRedbagConfigs(true)
      else
        Redbag.showCashRedbagConfigs(false)
    else
      Redbag.showEventInputs(true)
  
  # 处理现金红包配置的显示或隐藏
  Redbag.showCashRedbagConfigs($('#wechat-redbag-configs').data('is_cash') == '1')
  
  # 处理红包类型的切换
  Redbag.toggleRedbagType($('#redbag__type').val())
  
  $('#redbag__type').change ->
    Redbag.toggleRedbagType($(this).val())
  
  # EventForm.hideAll()
#   if $('#hb-type').val() == '0'
#     $('#hongbao_total_money_input').show()
#     $('#hongbao_min_value_input').show()
#     $('#hongbao_max_value_input').show()
#   else
#     $('#hongbao_value_input').show()
#     $('#hongbao_num_input').show()
#
#   # 新的红包信息
#   if $('#redbag__type').val() == '0'
#     $('#redbag_f_total_money_input').show()
#     $('#redbag_f_min_value_input').show()
#     $('#redbag_f_max_value_input').show()
#   else
#     $('#redbag_f_value_input').show()
#     $('#redbag_f_total_input').show()
#
#   if $('#redbag_redbag__type').val() == '0'
#     $('#redbag_redbag_f_total_money_input').show()
#     $('#redbag_redbag_f_min_value_input').show()
#     $('#redbag_redbag_f_max_value_input').show()
#   else
#     $('#redbag_redbag_f_value_input').show()
#     $('#redbag_redbag_f_total_input').show()
#
#   $('#redbag__type').change ->
#     EventForm.hideRedbagInputs()
#     val = $('#redbag__type').val()
#     if val == '1'
#       $('#redbag_f_value_input').show()
#       $('#redbag_f_total_input').show()
#     else if val == '0'
#       $('#redbag_f_total_money_input').show()
#       $('#redbag_f_min_value_input').show()
#       $('#redbag_f_max_value_input').show()
#     else
#       EventForm.hideRedbagInputs()
#   $('#redbag_redbag__type').change ->
#     EventForm.hideRedbagInputs2()
#     val = $('#redbag_redbag__type').val()
#     if val == '1'
#       $('#redbag_redbag_f_value_input').show()
#       $('#redbag_redbag_f_total_input').show()
#     else if val == '0'
#       $('#redbag_redbag_f_total_money_input').show()
#       $('#redbag_redbag_f_min_value_input').show()
#       $('#redbag_redbag_f_max_value_input').show()
#     else
#       EventForm.hideRedbagInputs2()
#
#   # 红包用途切换
#   if $('#redbag_use_type').val() == '2' || $('#redbag_use_type').val() == '3' || $('#redbag_use_type').val() == '6'
#     EventForm.hideShareRedbagInputs()
#   else
#     EventForm.showShareRedbagInputs()
#
#   $('#redbag_use_type').change ->
#     # alert($(this).val())
#     if $('#redbag_use_type').val() == '2' || $('#redbag_use_type').val() == '3' || $('#redbag_use_type').val() == '6'
#       EventForm.hideShareRedbagInputs()
#     else
#       EventForm.showShareRedbagInputs()
#
#   $('#hb-type').change ->
#     EventForm.hideHBInputs()
#     val = $('#hb-type').val()
#     if val == '1'
#       $('#hongbao_value_input').show()
#       $('#hongbao_num_input').show()
#     else if val == '0'
#       $('#hongbao_total_money_input').show()
#       $('#hongbao_min_value_input').show()
#       $('#hongbao_max_value_input').show()
#     else
#       EventForm.hideHBInputs()
#
#   # 判断是否显示
#   if $('#rule-type').val() == 'quiz'
#     $('#quiz-rule').show()
#   else if $('#rule-type').val() == 'checkin'
#     $('#checkin-rule').show()
#
#   $('#rule-type').change ->
#     EventForm.hideRuleInputs()
#     val = $('#rule-type').val()
#     if val == 'quiz'
#       $('#quiz-rule').show()
#     else if val == 'checkin'
#       $('#checkin-rule').show()
#     else
#       EventForm.hideRuleInputs()

$ ->
  # Clear Filters button
  $('.clear_filters_btn').off('click')
  $('.clear_filters_btn').click (e) ->
    params = window.location.search.slice(1).split('&')
    regex = /^(q\[|q%5B|q%5b|page|commit)/
    if typeof Turbolinks != 'undefined'
      Turbolinks.visit(window.location.href.split('?')[0] + '?clear_filters=1&' + (param for param in params when not param.match(regex)).join('&'))
      e.preventDefault()
    else
      window.location.search = 'clear_filters=1&' + (param for param in params when not param.match(regex)).join('&')
  