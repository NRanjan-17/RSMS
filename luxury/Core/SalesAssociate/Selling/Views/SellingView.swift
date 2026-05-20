//
//  SellingView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct SellingView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = SellingViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Catalog")
                        .font(AppFonts.serif(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(AppColors.surface)
                            .frame(width: 40, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 11).stroke(AppColors.gold15, lineWidth: 0.5))
                        
                        HStack(spacing: 2) {
                            ForEach(0..<4) { i in
                                Rectangle()
                                    .fill(AppColors.gold)
                                    .opacity(0.6)
                                    .frame(width: i == 3 || i == 1 ? 1.5 : 3, height: 14)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 14)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.tertiary)
                        
                        TextField("Search by name or SKU…", text: $viewModel.searchText)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                        
                        Button(action: {
                            router.presentFullScreen(SARoute.barcodeScanner)
                        }) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 18))
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold15, lineWidth: 0.5)
                    )
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categories, id: \.self) { cat in
                                let isSelected = viewModel.selectedCategory == cat
                                Text(cat)
                                    .font(AppFonts.sansSerif(size: 11, weight: isSelected ? .medium : .light))
                                    .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? AppColors.gold : Color.clear)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedCategory = cat
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 4)
                    
                    HStack(spacing: 10) {
                        CustomOutlineButton(title: "Look Builder", icon: AnyView(Image(systemName: "sparkles")), action: {
                            router.push(SARoute.lookBuilder)
                        })
                        
                        CustomOutlineButton(title: "Remote", icon: AnyView(Image(systemName: "video.fill")), action: {
                            router.push(SARoute.remoteSelling)
                        })
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(viewModel.filteredProducts) { product in
                            Button(action: {
                                router.push(SARoute.productDetail(product))
                            }) {
                                VStack(alignment: .leading, spacing: 0) {
                                    ZStack {
                                        Rectangle()
                                            .fill(AppColors.surface2)
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Image(systemName: "circle.grid.cross")
                                            .font(.system(size: 30))
                                            .foregroundStyle(AppColors.gold)
                                            .opacity(0.3)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.brand.uppercased())
                                            .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                            .kerning(1.5)
                                        
                                        Text(product.name)
                                            .font(AppFonts.serif(size: 14, weight: .medium))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        
                                        Text(product.price)
                                            .font(AppFonts.serif(size: 15, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                            .padding(.top, 2)
                                        
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(product.inStock ? AppColors.success : AppColors.error)
                                                .frame(width: 6, height: 6)
                                            Text(product.inStock ? "In Stock" : "Out of Stock")
                                                .font(AppFonts.sansSerif(size: 9))
                                                .foregroundStyle(product.inStock ? AppColors.success : AppColors.error)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding(10)
                                    .padding(.bottom, 2)
                                }
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.gold15, lineWidth: 0.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
