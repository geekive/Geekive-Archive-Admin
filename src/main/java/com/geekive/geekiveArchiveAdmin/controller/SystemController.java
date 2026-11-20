package com.geekive.geekiveArchiveAdmin.controller;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.geekive.geekiveArchiveAdmin.common.MessageUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.SystemService;

@Controller
@RequestMapping(value = "/system")
public class SystemController {
	
	@Resource
	SystemService systemService;

	@GetMapping(value = "/menu")
	public String menu(HttpServletRequest request, ModelMap modelMap) throws Exception{
		modelMap.put("title", "menu");
		return "system/menu/menu";
	}
	
	@ResponseBody
	@PostMapping(value = "/menu-list")
	public ModelMap menuList(HttpServletRequest request) throws Exception{
		
		ModelMap modelMap = new ModelMap();
		modelMap.addAttribute("resultCode", "1");
		List<Map<String, Object>> menuList = null;
		
		try {
			menuList = systemService.selectAllMenu();
			menuList = Util.hierarchicalSortList("menuUid", "parentMenuUid", "depth", "order", menuList);
		} catch (Exception e) {
			modelMap.addAttribute("resultCode"		, "0");
			modelMap.addAttribute("resultMessage"	, MessageUtil.getMessage("common.error"));
		}
		
		modelMap.addAttribute("menuList", menuList);
		return modelMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/save-menu")
	public GeekiveMap saveMenu(@RequestBody GeekiveMap gMap, HttpServletRequest request) throws Exception{
		try {
			String titleEn = gMap.getString("titleEn");
			String titleKo = gMap.getString("titleKo");
			if (titleEn == null || titleEn.trim().isEmpty()) {
				gMap.setResultCode(0);
				gMap.setResultMessage(MessageUtil.getMessage("settings.menuRequired"));
				return gMap;
			}
			titleEn = titleEn.trim();
			titleKo = titleKo == null ? null : titleKo.trim();
			if (titleEn.codePointCount(0, titleEn.length()) > 255 || (titleKo != null && titleKo.codePointCount(0, titleKo.length()) > 255)) {
				gMap.setResultCode(0);
				gMap.setResultMessage(MessageUtil.getMessage("settings.menuNameTooLong"));
				return gMap;
			}
			gMap.put("titleEn", titleEn);
			if (gMap.containsKey("titleKo")) {
				gMap.put("titleKo", titleKo);
			}
			String currentMode = gMap.getString("currentMode");
			if(currentMode.equals("add")) {
				gMap.put("menuUid", Util.generateUID("MNU"));
				systemService.insertMenu(gMap);
			}else if(currentMode.equals("edit")) {
				systemService.updateMenu(gMap);
			}
		} catch (Exception e) {
			gMap.put("resultCode"		, 0);
			gMap.put("resultMessage"	, MessageUtil.getMessage("common.error"));
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/delete-menu")
	public GeekiveMap deleteMenu(@RequestBody GeekiveMap gMap, HttpServletRequest request) throws Exception{
		try {
			systemService.deleteMenu(gMap);
		} catch (Exception e) {
			gMap.put("resultCode"		, 0);
			gMap.put("resultMessage"	, MessageUtil.getMessage("common.error"));
		}
		return gMap;
	}
	
	@GetMapping(value = "/test")
	public String test(HttpServletRequest request, ModelMap modelMap) throws Exception{
		return "system/menu/test";
	}
}
