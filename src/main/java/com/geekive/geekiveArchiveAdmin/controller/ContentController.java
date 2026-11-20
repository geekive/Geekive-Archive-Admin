package com.geekive.geekiveArchiveAdmin.controller;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.geekive.geekiveArchiveAdmin.common.Constants;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveConnector;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekivePaginator;
import com.geekive.geekiveArchiveAdmin.mapper.service.CommonService;
import com.geekive.geekiveArchiveAdmin.mapper.service.ContentService;

@Controller
@RequestMapping(value = "/content")
public class ContentController {
	
	@Resource
	ContentService contentService;
	
	@Resource
	CommonService commonService;

	@GetMapping(value = "/article/list")
	public String articleList(HttpServletRequest request, ModelMap modelMap) throws Exception{
		// parameter :: s
		String[] categoryUidArray 	= request.getParameterValues("categoryUid");
		String searchOption 		= request.getParameter("searchOption");
		String searchValue 			= request.getParameter("searchValue");
		
		modelMap.put("categoryUidCSV"	, Util.arrayToCSV(categoryUidArray));
		modelMap.put("searchOption"		, searchOption);
		modelMap.put("searchValue"		, searchValue);
		// parameter :: e
		
		int currentPageNumber = GeekivePaginator.parseCurrentPageNumber(request.getParameter("currentPageNumber"));
		
		GeekiveMap gMap = new GeekiveMap();
		gMap.put("dataCountPerPage"	, Constants.dataCountPerPage);
		gMap.put("dataPagingIndex"	, (currentPageNumber * Constants.dataCountPerPage) - Constants.dataCountPerPage);
		gMap.put("categoryUidArray"	, categoryUidArray);
		gMap.put("searchOption"		, searchOption);
		gMap.put("searchValue"		, searchValue);
		
		int articleTotalCount = contentService.selectArticleListCount(gMap);
		
		GeekivePaginator gPaginator = new GeekivePaginator.Builder().currentPageNumber(currentPageNumber).dataTotalCount(articleTotalCount).build();
		GeekiveMap paginationMap 	= gPaginator.getPaginationMap();
		
		List<GeekiveMap> articleList = contentService.selectArticleList(gMap);		
		modelMap.put("title"			, "article");
		modelMap.put("articleList"		, articleList);
		modelMap.put("paginationMap"	, paginationMap);

		return "content/article/list";
	}
	
	@GetMapping(value = "/article/view")
	public String articleView(HttpServletRequest request, ModelMap modelMap) throws Exception{
		String articleUid = request.getParameter("articleUid");
		
		if(Util.isEmpty(articleUid)) {return "redirect:/";}
		
		GeekiveMap parameterMap = new GeekiveMap();
		parameterMap.put("articleUid", articleUid);
		
		GeekiveMap articleMap = contentService.selectArticleForView(parameterMap);
		modelMap.put("title"		, "article");
		modelMap.put("articleMap"	, articleMap);
		return "content/article/view";
	}
	
	@GetMapping(value = "/article/write")
	public String articleWrite(HttpServletRequest request, ModelMap modelMap) throws Exception{		
		String articleUid = request.getParameter("articleUid");
		
		if(Util.isNotEmpty(articleUid)) {
			GeekiveMap parameterMap = new GeekiveMap();
			parameterMap.put("articleUid", articleUid);
			
			GeekiveMap articleMap = contentService.selectArticleForEdit(parameterMap);
			if(Util.isEmpty(articleMap)) {
				return "redirect:/content/article/list";
			}
			modelMap.put("articleMap", articleMap);
		}
		modelMap.put("title", "article");
		return "content/article/write";
	}
	
	@ResponseBody
	@PostMapping(value = "/article/save", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE})
	public GeekiveMap articleSave(@RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail, @RequestPart("data") GeekiveMap gMap) throws Exception{
		
		String url = Util.getFileServerUploadUrl() + "/file";

		try {
			Object flagPrivate = gMap.get("flagPrivate");
			if (gMap.containsKey("flagPrivate") && !"Y".equals(flagPrivate) && !"N".equals(flagPrivate)) {
				gMap.put("resultCode", 0);
				gMap.put("resultMessage", "select a valid private setting.");
				return gMap;
			}
			if(thumbnail != null) {
				GeekiveConnector gConntector = new GeekiveConnector.Builder(url).data(thumbnail).build();
				GeekiveMap responseMap = gConntector.sendMultiPartFile("file");
				gMap.put("thumbnailUid"	, responseMap.getString("fileUid"));
			}

			if(Util.isEmpty(gMap.getString("articleUid"))) { 
				gMap.put("articleUid", Util.generateUID("ATC"));
			} 
			contentService.upsertArticle(gMap);
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/article/delete")
	public GeekiveMap articleDelete(@RequestBody GeekiveMap gMap) throws Exception{
		try {
			if(Util.isNotEmpty(gMap.getString("articleUid"))) { 
				contentService.deleteArticle(gMap);
			}else {
				gMap.put("resultCode"	, 0);
				gMap.put("resultMessage", "cannot find key value.");
			}
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
	
	@GetMapping(value = "/category")
	public String category(ModelMap modelMap) throws Exception{
		modelMap.put("title", "category");
		return "content/category/category";
	}
	
	@PostMapping(value = "/category-list")
	public String categoryList(HttpServletRequest request, ModelMap modelMap) throws Exception{
		List<Map<String, Object>> categoryList = null;
		try {
			categoryList = contentService.selectCategory(new GeekiveMap());
			if(categoryList != null && categoryList.size() > 0) {
				categoryList = Util.hierarchicalSortList("categoryUid", "parentCategoryUid", "depth", "order", categoryList);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		modelMap.put("categoryList", categoryList);
		return "content/category/category-list";
	}
	
	@ResponseBody
	@PostMapping(value = "/save-category-order")
	public GeekiveMap saveCategoryOrder(@RequestBody GeekiveMap gMap) throws Exception{
		try {
			String[] categoryArray = gMap.getStringArray("categoryArray");
			for(int i = 0; i < categoryArray.length; i++) {
				GeekiveMap category = new GeekiveMap();
				category.put("categoryUid"	, categoryArray[i]);
				category.put("order"		, i + 1);
				contentService.updateCategoryOrder(category);
			}
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/save-category")
	public GeekiveMap saveCategory(@RequestBody GeekiveMap gMap, HttpServletRequest request) throws Exception{
		try {
			String currentMode = gMap.getString("currentMode");
			if(currentMode.equals("add")) {
				gMap.put("categoryUid", Util.generateUID("CTG"));
				contentService.insertCategory(gMap);
			}else if(currentMode.equals("edit")) {
				contentService.updateCategory(gMap);
			}
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/delete-category")
	public GeekiveMap deleteCategory(@RequestBody GeekiveMap gMap, HttpServletRequest request) throws Exception{
		try {
			contentService.deleteCategory(gMap);
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
}
