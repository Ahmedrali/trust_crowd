$ ->
  bindCollapse()
  
  $(".prob").bind "ajax:complete", (et, e) ->
    $("#alternatives_content").html '<p class="text-center"> ... </p>'
    $("#criteria_content").html '<p class="text-center"> ... </p>'
    $("#prob_desc").html e.responseText
    id = $(this).attr("id")
    handleCriteria id
    handleAlternatives id

handleCriteria = (id) ->
  getActiveCriteria id
  getRejectedCriteria id
  bindCreateCriteria id
  hideCriteriaContentArea()

handleAlternatives = (id) ->
  getActiveAlternatives id
  getRejectedAlternatives id
  bindCreateAlternative id
  hideAlternativesContentArea()
    
bindCollapse = ->
  $("#alternatives_content_switch").on "click", ->
    if($("#alternatives_content").hasClass("in"))
      hideAlternativesContentArea()
    else
      showAlternativesContentArea()
  
  $("#criteria_content_switch").on "click", ->
    if($("#criteria_content").hasClass("in"))
      hideCriteriaContentArea()      
    else
      showCriteriaContentArea()

getActiveAlternatives = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives'
    type: "get"
    success: (resp) ->
      bindActiveAlternativesLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

getRejectedAlternatives = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives/rejected'
    type: "get"
    success: (resp) ->
      bindRejectedAlternativesLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

bindActiveAlternativesLinks = (id, resp) ->
  $("#prob_active_alts").html resp
  
  $(".alt-details").bind "ajax:complete", (et, e) ->
    showAlternativesContentArea()
    $("#alternatives_content").html e.responseText
  
  $(".alt-edit").bind "ajax:complete", (et, e) ->
    showAlternativesContentArea()
    $("#alternatives_content").html e.responseText
    bindCreateNewAlternativeAction id
  
  $(".alt-reject").bind "ajax:complete", (et, e) ->
    getActiveAlternatives id
    getRejectedAlternatives id
    
  altActivePagination id

bindRejectedAlternativesLinks = (id, resp) ->
  $("#prob_rejected_alts").html resp
  $(".alt-active").bind "ajax:complete", (et, e) ->
    getActiveAlternatives id
    getRejectedAlternatives id
  altRejectedPagination id
  
createNewAlternative = (id) ->
  $.ajax
    url: '/problems/' + id + '/alternatives/new'
    type: "get"
    success: (resp) ->
      $("#alternatives_content").html resp
      bindCreateNewAlternativeAction id
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

bindCreateNewAlternativeAction = (id) ->
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
      getActiveAlternatives id
    else
      $("#alternatives_content").html res
      bindCreateNewAlternativeAction id

showAlternativesContentArea = ->
  if(!$("#alternatives_content").hasClass("in"))
    $("#alternatives_content").collapse('show')
    $("#alternatives_content_switch").html '<i class="icon-chevron-up"></i>'

hideAlternativesContentArea = ->
  if($("#alternatives_content").hasClass("in"))
    $("#alternatives_content").collapse('hide')
    $("#alternatives_content_switch").html '<i class="icon-chevron-down"></i>'

bindCreateAlternative = (id) ->
  $("#create_new_alternative").on "click", ->
    createNewAlternative id
    showAlternativesContentArea()

altActivePagination = (id) ->
  if($(".alt-active-pagination").length > 0)
    $(".alt-active-pagination").addClass "pagination-centered"
    $('.alt-active-pagination a').attr("data-remote", "true")
    $('.alt-active-pagination a').wrap "<li />"
    $('.alt-active-pagination span').wrap "<li />"
    $('.alt-active-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.alt-active-pagination li').wrapAll "<ul />"
    $('.alt-active-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      bindActiveAlternativesLinks id, resp

altRejectedPagination = (id) ->
  if($(".alt-rejected-pagination").length > 0)
    $(".alt-rejected-pagination").addClass "pagination-centered"
    $('.alt-rejected-pagination a').attr("data-remote", "true")
    $('.alt-rejected-pagination a').wrap "<li />"
    $('.alt-rejected-pagination span').wrap "<li />"
    $('.alt-rejected-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.alt-rejected-pagination li').wrapAll "<ul />"
    $('.alt-rejected-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      bindRejectedAlternativesLinks id, resp
      
## ----------------
## Criteria Methods
## ----------------

getActiveCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria'
    type: "get"
    success: (resp) ->
      bindActiveCriteriaLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

getRejectedCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria/rejected'
    type: "get"
    success: (resp) ->
      bindRejectedCriteriaLinks id, resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

bindActiveCriteriaLinks = (id, resp) ->
  $("#prob_active_criteria").html resp
  
  $(".criteria-details").bind "ajax:complete", (et, e) ->
    showCriteriaContentArea()
    $("#criteria_content").html e.responseText
  
  $(".criteria-edit").bind "ajax:complete", (et, e) ->
    showCriteriaContentArea()
    $("#criteria_content").html e.responseText
    bindCreateNewCriteriaAction id
  
  $(".criteria-reject").bind "ajax:complete", (et, e) ->
    getActiveCriteria id
    getRejectedCriteria id
    
  criteriaActivePagination id

bindRejectedCriteriaLinks = (id, resp) ->
  $("#prob_rejected_criteria").html resp
  $(".criteria-active").bind "ajax:complete", (et, e) ->
    getActiveCriteria id
    getRejectedCriteria id
  criteriaRejectedPagination id

createNewCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria/new'
    type: "get"
    success: (resp) ->
      $("#criteria_content").html resp
      bindCreateNewCriteriaAction id
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

bindCreateNewCriteriaAction = (id) ->
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
      getActiveCriteria id
    else
      $("#criteria_content").html res
      bindCreateNewCriteriaAction id

showCriteriaContentArea = ->
  if(!$("#criteria_content").hasClass("in"))
    $("#criteria_content").collapse('show')
    $("#criteria_content_switch").html '<i class="icon-chevron-up"></i>'

hideCriteriaContentArea = ->
  if($("#criteria_content").hasClass("in"))
    $("#criteria_content").collapse('hide')
    $("#criteria_content_switch").html '<i class="icon-chevron-down"></i>'

bindCreateCriteria = (id) ->
  $("#create_new_criteria").on "click", ->
    createNewCriteria id
    showCriteriaContentArea()

criteriaActivePagination = (id) ->
  if($(".criteria-active-pagination").length > 0)
    $(".criteria-active-pagination").addClass "pagination-centered"
    $('.criteria-active-pagination a').attr("data-remote", "true")
    $('.criteria-active-pagination a').wrap "<li />"
    $('.criteria-active-pagination span').wrap "<li />"
    $('.criteria-active-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.criteria-active-pagination li').wrapAll "<ul />"
    $('.criteria-active-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      bindActiveCriteriaLinks id, resp

criteriaRejectedPagination = (id) ->
  if($(".criteria-rejected-pagination").length > 0)
    $(".criteria-rejected-pagination").addClass "pagination-centered"
    $('.criteria-rejected-pagination a').attr("data-remote", "true")
    $('.criteria-rejected-pagination a').wrap "<li />"
    $('.criteria-rejected-pagination span').wrap "<li />"
    $('.criteria-rejected-pagination em').wrapInner('<span />').wrapInner('<li class="active" />')
    $('.criteria-rejected-pagination li').wrapAll "<ul />"
    $('.criteria-rejected-pagination a').bind "ajax:complete", (et, e) ->
      resp = e.responseText
      bindRejectedCriteriaLinks id, resp
