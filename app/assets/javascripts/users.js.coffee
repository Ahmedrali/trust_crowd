window.tc = {};

window.tc.getProblems = (status) ->
  $.ajax({
      type: "GET",
      url: "/problems",
      data: {"status": status},
      dataType: "script",
      success: ->
        $(".prob").bind "ajax:complete", (et, e) ->
          id = $(this).attr("id")
          tc.showProblemDetails(id, e.responseText)
  });

window.tc.showProblemDetails = (id, prob_desc) ->
  $("#problem_details").show()
  $("#ahp_evaluation").hide()
  $("#new_problem").hide()
  $("#alternatives_content").html '<p class="text-center"> ... </p>'
  $("#criteria_content").html '<p class="text-center"> ... </p>'
  $("#prob_desc").html prob_desc
  tc.bindEvaluateAction()
  tc.bindEvaluateCriteriaAction()
  tc.bindEditProblemAction()
  tc.bindActiveProblemAction()
  tc.bindCloseProblemAction()
  tc.handleCriteria id
  tc.handleAlternatives id

window.tc.handleCriteria = (id) ->
  tc.getActiveCriteria id
  tc.getRejectedCriteria id
  tc.bindCreateCriteria id
  tc.hideCriteriaContentArea()

window.tc.handleAlternatives = (id) ->
  tc.getActiveAlternatives id
  tc.getRejectedAlternatives id
  tc.bindCreateAlternative id
  tc.hideAlternativesContentArea()
    
window.tc.bindCollapse = ->
  $("#alternatives_content_switch").on "click", ->
    if($("#alternatives_content").hasClass("in"))
      tc.hideAlternativesContentArea()
    else
      tc.showAlternativesContentArea()
  
  $("#criteria_content_switch").on "click", ->
    if($("#criteria_content").hasClass("in"))
      tc.hideCriteriaContentArea()      
    else
      tc.showCriteriaContentArea()

## --------------------
## Alternatives Methods
## --------------------

window.tc.getActiveAlternatives = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives'
    type: "get"
    success: (resp) ->
      tc.bindActiveAlternativesLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.getRejectedAlternatives = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives/rejected'
    type: "get"
    success: (resp) ->
      tc.bindRejectedAlternativesLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.bindActiveAlternativesLinks = (id, resp) ->
  $("#prob_active_alts").html resp
  
  $(".alt-details").bind "ajax:complete", (et, e) ->
    tc.showAlternativesContentArea()
    $("#alternatives_content").html e.responseText
  
  $(".alt-edit").bind "ajax:complete", (et, e) ->
    tc.showAlternativesContentArea()
    $("#alternatives_content").html e.responseText
    tc.bindCreateNewAlternativeAction id
  
  $(".alt-reject").bind "ajax:complete", (et, e) ->
    tc.getActiveAlternatives id
    tc.getRejectedAlternatives id
    
  tc.altActivePagination id

window.tc.bindRejectedAlternativesLinks = (id, resp) ->
  $("#prob_rejected_alts").html resp
  $(".alt-active").bind "ajax:complete", (et, e) ->
    tc.getActiveAlternatives id
    tc.getRejectedAlternatives id
  tc.altRejectedPagination id
  
window.tc.createNewAlternative = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives/new'
    type: "get"
    success: (resp) ->
      $("#alternatives_content").html resp
      tc.bindCreateNewAlternativeAction id
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.bindCreateNewAlternativeAction = (id) ->
  $(".alt-form").bind "ajax:complete", (et, e) ->
    res = e.responseText
    if($.isNumeric( res ))
      $.ajax
        url: '/problems/' + id + '/alternatives/' + res
        type: "get"
        success: (resp) ->
          $("#alternatives_content").html resp
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
      tc.getActiveAlternatives id
    else
      $("#alternatives_content").html res
      tc.bindCreateNewAlternativeAction id

window.tc.showAlternativesContentArea = ->
  if(!$("#alternatives_content").hasClass("in"))
    $("#alternatives_content").collapse('show')
    $("#alternatives_content_switch").html '<i class="icon-chevron-up"></i>'

window.tc.hideAlternativesContentArea = ->
  if($("#alternatives_content").hasClass("in"))
    $("#alternatives_content").collapse('hide')
    $("#alternatives_content_switch").html '<i class="icon-chevron-down"></i>'

window.tc.bindCreateAlternative = (id) ->
  $("#create_new_alternative").on "click", ->
    tc.createNewAlternative id
    tc.showAlternativesContentArea()

window.tc.altActivePagination = (id) ->
  if($(".alt-active-pagination").length > 0)
    $(".alt-active-pagination").addClass "pagination-centered"
    $('.alt-active-pagination a').attr("data-remote", "true")
    $('.alt-active-pagination a').wrap "<li />"
    $('.alt-active-pagination span').wrap "<li />"
    $('.alt-active-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.alt-active-pagination li').wrapAll "<ul />"
    $('.alt-active-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      tc.bindActiveAlternativesLinks id, resp

window.tc.altRejectedPagination = (id) ->
  if($(".alt-rejected-pagination").length > 0)
    $(".alt-rejected-pagination").addClass "pagination-centered"
    $('.alt-rejected-pagination a').attr("data-remote", "true")
    $('.alt-rejected-pagination a').wrap "<li />"
    $('.alt-rejected-pagination span').wrap "<li />"
    $('.alt-rejected-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.alt-rejected-pagination li').wrapAll "<ul />"
    $('.alt-rejected-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      tc.bindRejectedAlternativesLinks id, resp
      
## ----------------
## Criteria Methods
## ----------------

window.tc.getActiveCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria'
    type: "get"
    success: (resp) ->
      tc.bindActiveCriteriaLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.getRejectedCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria/rejected'
    type: "get"
    success: (resp) ->
      tc.bindRejectedCriteriaLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.bindActiveCriteriaLinks = (id, resp) ->
  $("#prob_active_criteria").html resp
  
  $(".criteria-details").bind "ajax:complete", (et, e) ->
    tc.showCriteriaContentArea()
    $("#criteria_content").html e.responseText
  
  $(".criteria-edit").bind "ajax:complete", (et, e) ->
    tc.showCriteriaContentArea()
    $("#criteria_content").html e.responseText
    tc.bindCreateNewCriteriaAction id
  
  $(".criteria-reject").bind "ajax:complete", (et, e) ->
    tc.getActiveCriteria id
    tc.getRejectedCriteria id
    
  tc.criteriaActivePagination id

window.tc.bindRejectedCriteriaLinks = (id, resp) ->
  $("#prob_rejected_criteria").html resp
  $(".criteria-active").bind "ajax:complete", (et, e) ->
    tc.getActiveCriteria id
    tc.getRejectedCriteria id
  tc.criteriaRejectedPagination id

window.tc.createNewCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria/new'
    type: "get"
    success: (resp) ->
      $("#criteria_content").html resp
      tc.bindCreateNewCriteriaAction id
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.bindCreateNewCriteriaAction = (id) ->
  $(".criteria-form").bind "ajax:complete", (et, e) ->
    res = e.responseText
    if($.isNumeric( res ))
      $.ajax
        url: '/problems/' + id + '/criteria/' + res
        type: "get"
        success: (resp) ->
          $("#criteria_content").html resp
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
      tc.getActiveCriteria id
    else
      $("#criteria_content").html res
      tc.bindCreateNewCriteriaAction id

window.tc.showCriteriaContentArea = ->
  if(!$("#criteria_content").hasClass("in"))
    $("#criteria_content").collapse('show')
    $("#criteria_content_switch").html '<i class="icon-chevron-up"></i>'

window.tc.hideCriteriaContentArea = ->
  if($("#criteria_content").hasClass("in"))
    $("#criteria_content").collapse('hide')
    $("#criteria_content_switch").html '<i class="icon-chevron-down"></i>'

window.tc.bindCreateCriteria = (id) ->
  $("#create_new_criteria").on "click", ->
    tc.createNewCriteria id
    tc.showCriteriaContentArea()

window.tc.criteriaActivePagination = (id) ->
  if($(".criteria-active-pagination").length > 0)
    $(".criteria-active-pagination").addClass "pagination-centered"
    $('.criteria-active-pagination a').attr("data-remote", "true")
    $('.criteria-active-pagination a').wrap "<li />"
    $('.criteria-active-pagination span').wrap "<li />"
    $('.criteria-active-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.criteria-active-pagination li').wrapAll "<ul />"
    $('.criteria-active-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      tc.bindActiveCriteriaLinks id, resp

window.tc.criteriaRejectedPagination = (id) ->
  if($(".criteria-rejected-pagination").length > 0)
    $(".criteria-rejected-pagination").addClass "pagination-centered"
    $('.criteria-rejected-pagination a').attr("data-remote", "true")
    $('.criteria-rejected-pagination a').wrap "<li />"
    $('.criteria-rejected-pagination span').wrap "<li />"
    $('.criteria-rejected-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.criteria-rejected-pagination li').wrapAll "<ul />"
    $('.criteria-rejected-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      tc.bindRejectedCriteriaLinks id, resp

## ---------------
## Problem Methods
## ---------------

window.tc.bindCreateNewProblem = ->
  $("#create_new_problem").on "click", ->
    tc.createNewProblem()

window.tc.createNewProblem = ->
  $.ajax
    url: '/problems/new'
    type: "get"
    success: (resp) ->
      $("#problem_details").hide()
      $("#new_problem").show()
      
      $("#new_problem").html resp
      tc.bindCreateNewProblemAction()
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

window.tc.bindCreateNewProblemAction = ->
  $(".problem-form").bind "ajax:complete", (et, e) ->
    id = e.responseText
    if($.isNumeric( id ))
      $.ajax
        url: '/problems/'+id
        type: "get"
        success: (resp) ->
          tc.showProblemDetails(id, resp)
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
    else
      $("#new_problem").html res
      tc.bindCreateNewProblemAction()

window.tc.bindActiveProblemAction = ->
  $(".problem-activate").bind "ajax:complete", (et, e) ->
    tc.getProblems("pending")
    tc.getProblems("active")
    id = e.responseText
    if($.isNumeric( id ))
      $.ajax
        url: '/problems/'+id
        type: "get"
        success: (resp) ->
          tc.showProblemDetails(id, resp)
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
    else
      alert("Sorry, something went wrong, please contact admin for helping.")

window.tc.bindCloseProblemAction = ->
  $(".problem-close").bind "ajax:complete", (et, e) ->
    tc.getProblems("active")
    tc.getProblems("closed")
    id = e.responseText
    if($.isNumeric( id ))
      $.ajax
        url: '/problems/'+id
        type: "get"
        success: (resp) ->
          tc.showProblemDetails(id, resp)
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
    else
      alert("Sorry, something went wrong, please contact admin for helping.")

window.tc.bindEvaluateAction = ->
  $(".problem-evaluate").bind "ajax:complete", (et, e) ->
    $("#problem_details").hide()
    $("#ahp_evaluation").show()
    $("#ahp_evaluation").html e.responseText
    tc.bindFinishEvaluateAction()

window.tc.bindEvaluateCriteriaAction = ->
  $(".problem-evaluate-criteria").bind "ajax:complete", (et, e) ->
    $("#problem_details").hide()
    $("#ahp_evaluation").show()
    $("#ahp_evaluation").html e.responseText
    tc.bindFinishEvaluateAction()

window.tc.bindFinishEvaluateAction = ->
  $(".problem-finish-evaluate").bind "ajax:complete", (et, e) ->
    id = e.responseText
    if($.isNumeric( id ))
      $.ajax
        url: '/problems/'+id
        type: "get"
        success: (resp) ->
          tc.showProblemDetails(id, resp)
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
    else
      alert(id)

window.tc.bindEditProblemAction = ->
  $(".problem-edit").bind "ajax:complete", (et, e) ->
    $("#prob_desc").html e.responseText
    tc.bindUpdateProblemAction()

window.tc.bindUpdateProblemAction = ->
  $(".problem-form").bind "ajax:complete", (et, e) ->
    id = e.responseText
    if($.isNumeric( id ))
      $.ajax
        url: '/problems/'+id
        type: "get"
        success: (resp) ->
          tc.showProblemDetails(id, resp)
        error: (xhr, ajaxOptions, thrownError)->
          alert(thrownError)
        cache: false
    else
      $("#prob_desc").html id
      tc.bindUpdateProblemAction()

##------------
## Decisions
##------------

window.tc.getIndvDecision = (div, id) ->
  $.ajax
    url: '/indv'
    data: {'prob': id}
    type: "get"
    success: (resp) ->
      data = []
      for r in Object.keys(resp)
        data.push([ r, resp[r] ])
      window.tc.plotPieChart(div, data, 'My Evaluation')
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false
  
window.tc.getGroupDecision = (div, id) ->
  $.ajax
    url: '/coll'
    data: {'prob': id}
    type: "get"
    success: (resp) ->
      data = []
      for r in Object.keys(resp)
        data.push([ r, resp[r] ])
      window.tc.plotPieChart(div, data, 'Group Evaluation')
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

##------------
## Graphs
##------------

window.tc.plotPieChart = (div, data, title) ->
  $('#'+div).highcharts({
    chart:{
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            backgroundColor: 'rgba(0,0,0,0)'
          },
    credits:{
            enabled: false
          },
    title:{
            text: title
          },
    tooltip:{
            pointFormat: '{series.name}: <b>{point.percentage:.2f}%</b>'
          },
    plotOptions: {
      pie:{
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels:{
              enabled: true,
              color: '#000000',
              connectorColor: '#000000',
              format: '<b>{point.name}</b>: {point.percentage:.1f} %'
            },
            showInLegend: true
          }
          },
    series:[{
            type: 'pie',
            name: 'Alternatives Score',
            data: data
          }]
      });
