$ ->
  bindCollapse()
  
  $(".prob").bind "ajax:complete", (et, e) ->
    $("#alternatives_content").html '<p class="text-center"> ... </p>'
    $("#prob_desc").html e.responseText
    id = $(this).attr("id")
    getCriteria id
    createNewCriterium id
    
    getActiveAlternatives id
    getRejectedAlternatives id
    bindCreateAlternative id
    
    hideAlternativesContentArea()
    
getCriteria = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria'
    type: "get"
    success: (resp) ->
      $("#prob_criteria").html resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

createNewCriterium = (id) ->
  $.ajax
    url: '/problems/' + id + '/criteria/new'
    type: "get"
    success: (resp) ->
      $("#new_criteria").html resp
    error: (xhr, ajaxOptions, thrownError)->
      alert(thrownError)
    cache: false

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
      
bindCollapse = ->
  $("#alternatives_content_switch").on "click", ->
    if($("#alternatives_content").hasClass("in"))
      hideAlternativesContentArea()
    else
      showAlternativesContentArea()

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
      