package com.geekive.geekiveArchiveAdmin.controller;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;

import com.geekive.geekiveArchiveAdmin.common.MessageUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.CommonService;

@Controller
public class CommonController {

	@Resource
	CommonService commonService;

	@GetMapping(value = "/menu")
	public String menu(HttpServletRequest request, ModelMap modelMap) throws Exception{
		List<Map<String, Object>> menuList = null;
		String profileImageUrlPath = null;
		try {
			String subPath = request.getAttribute("subPath").toString();
			GeekiveMap gMap = new GeekiveMap();
			gMap.put("subPathArray", Util.splitSubPath(subPath));
			gMap.put("korean", MessageUtil.isKorean());
			
			profileImageUrlPath = commonService.selectProfileImageUrlPath(gMap);
			menuList 			= commonService.selectAllMenu(gMap);
			menuList 			= Util.hierarchicalSortList("menuUid", "parentMenuUid", "depth", "order", menuList);
		} catch (Exception e) {
			e.getStackTrace();
		}
		modelMap.addAttribute("profileImageUrlPath"	, profileImageUrlPath);
		modelMap.addAttribute("menuList"			, menuList);
		return "common/menu";
	}
}
