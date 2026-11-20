package com.geekive.geekiveArchiveAdmin.controller;

import java.util.ArrayList;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveConnector;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.CommonService;
import com.geekive.geekiveArchiveAdmin.mapper.service.OptionService;
import com.geekive.geekiveArchiveAdmin.vo.OptionVO;

@Controller
@RequestMapping(value = "/option")
public class OptionController {
	
	@Resource
	OptionService optionService;

	@GetMapping(value = "/checkbox")
	public String checkbox(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		
		List<OptionVO> checkboxList = new ArrayList<OptionVO>();
		
		String codeType = optionVO.getCodeType();
		if(Util.isNotEmpty(codeType)) {
			if(optionService.isCommonCode(optionVO)) {
				checkboxList = optionService.selectCode(optionVO);
			}else {
				switch (codeType) {
				case "category"	: {checkboxList = optionService.selectCategory(optionVO); break;}
				default			: throw new IllegalArgumentException("Unexpected value: " + codeType);}
			}
		}
		
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("all"			, optionVO.getAll());
		modelMap.put("hide"			, optionVO.getHide());
		modelMap.put("data"			, Util.CSVToArray(optionVO.getData()));
		modelMap.put("checkboxList"	, checkboxList);
		return "option/checkbox";
	}
	
	@GetMapping(value = "/radio")
	public String radio(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		
		List<OptionVO> radioList = new ArrayList<OptionVO>();
		
		String codeType = optionVO.getCodeType();
		if(Util.isNotEmpty(codeType)) {
			if(optionService.isCommonCode(optionVO)) {
				radioList = optionService.selectCode(optionVO);
			}else {
				switch (codeType) {
				case "category"	: {radioList = optionService.selectCategory(optionVO); break;}
				default			: throw new IllegalArgumentException("Unexpected value: " + codeType);}
			}
		}
		
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("hide"			, optionVO.getHide());
		modelMap.put("data"			, optionVO.getData());
		modelMap.put("radioList"	, radioList);
		return "option/radio";
	}

	@GetMapping(value = "/article-viewers")
	public String articleViewers(ModelMap modelMap, OptionVO optionVO) {
		modelMap.put("optionLabel", optionVO.getOptionLabel());
		modelMap.put("hide", optionVO.getHide());
		return "option/article-viewers";
	}
	
	@GetMapping(value = "/search")
	public String search(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		optionVO.setCodeType("SEARCH_OPTION");
		List<OptionVO> selectList = optionService.selectCode(optionVO);
		
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("selectName"	, optionVO.getSelectName());
		modelMap.put("selectData"	, optionVO.getSelectData());
		modelMap.put("selectList"	, selectList);
		modelMap.put("textName"		, optionVO.getTextName());
		modelMap.put("textData"		, optionVO.getTextData());
		modelMap.put("hide"			, optionVO.getHide());
		return "option/search";
	}
	
	@GetMapping(value = "/text")
	public String text(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("placeholder"	, optionVO.getPlaceholder());
		modelMap.put("readonly"		, optionVO.getReadonly());
		modelMap.put("maxlength"	, optionVO.getMaxlength());
		modelMap.put("hide"			, optionVO.getHide());
		modelMap.put("data"			, optionVO.getData());
		return "option/text";
	}
	
	@GetMapping(value = "/password")
	public String password(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("id"			, optionVO.getId());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("placeholder"	, optionVO.getPlaceholder());
		modelMap.put("readonly"		, optionVO.getReadonly());
		modelMap.put("maxlength"	, optionVO.getMaxlength());
		modelMap.put("hide"			, optionVO.getHide());
		modelMap.put("data"			, optionVO.getData());
		return "option/password";
	}
	
	@GetMapping(value = "/select")
	public String select(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("hide"			, optionVO.getHide());
		return "option/select";
	}
	
	@GetMapping(value = "/tinymce")
	public String tinymce(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("id"			, optionVO.getId());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("height"		, optionVO.getHeight());
		modelMap.put("width"		, optionVO.getWidth());
		modelMap.put("data"			, optionVO.getData());
		return "option/tinymce";
	}
	
	@ResponseBody
	@PostMapping(value = "/upload-tinymce")
	public GeekiveMap uploadTinymce(MultipartHttpServletRequest request) throws Exception{
		GeekiveMap responseMap 	= new GeekiveMap();
		String url 				= Util.getFileServerUploadUrl() + "/file";
		try {
			MultipartFile tinymce 			= request.getFile("tinymce");
			GeekiveConnector gConntector 	= new GeekiveConnector.Builder(url).data(tinymce).build();
			responseMap 					= gConntector.sendMultiPartFile("file");
		} catch (Exception e) {
			responseMap.put("resultCode"	, 0);
			responseMap.put("resultMessage", e.getMessage());
		}
		return responseMap;
	}
	
	@GetMapping(value = "/image")
	public String image(HttpServletRequest request, ModelMap modelMap, OptionVO optionVO) throws Exception{
		modelMap.put("optionLabel"	, optionVO.getOptionLabel());
		modelMap.put("id"			, optionVO.getId());
		modelMap.put("name"			, optionVO.getName());
		modelMap.put("hide"			, optionVO.getHide());
		modelMap.put("crop"			, optionVO.getCrop());
		modelMap.put("preview"		, optionVO.getPreview());
		modelMap.put("data"			, optionService.selectFile(optionVO));
		return "option/image";
	}
}
