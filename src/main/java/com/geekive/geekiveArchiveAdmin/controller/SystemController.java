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
			modelMap.addAttribute("resultMessage"	, e.getMessage());
		}
		
		modelMap.addAttribute("menuList", menuList);
		return modelMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/save-menu")
	public GeekiveMap saveMenu(@RequestBody GeekiveMap gMap, HttpServletRequest request) throws Exception{
		try {
			String currentMode = gMap.getString("currentMode");
			if(currentMode.equals("add")) {
				gMap.put("menuUid", Util.generateUID("MNU"));
				systemService.insertMenu(gMap);
			}else if(currentMode.equals("edit")) {
				systemService.updateMenu(gMap);
			}
		} catch (Exception e) {
			gMap.put("resultCode"		, 0);
			gMap.put("resultMessage"	, e.getMessage());
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
			gMap.put("resultMessage"	, e.getMessage());
		}
		return gMap;
	}
	
	@GetMapping(value = "/test")
	public String test(HttpServletRequest request, ModelMap modelMap) throws Exception{
		return "system/menu/test";
	}
}
