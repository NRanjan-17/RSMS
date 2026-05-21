//
//  ProductFormView.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import SwiftUI

struct ProductFormView: View {
    @Environment(CatalogsViewModel.self) private var viewModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    var editProduct: ProductEntity?
    
    @State private var showingScanner = false
    
    var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {

                        
                        Text(editProduct != nil ? "Edit\nProduct." : "Catalog\nEntry.")
                            .font(AppFonts.serif(size: 52, weight: .light))
                            .italic()
                            .foregroundStyle(AppColors.text)
                            .lineSpacing(-5)
                            .padding(.bottom, 16)
                        
                        Text(editProduct != nil ? "Update the details for this product" : "Add a new product to the catalog")
                            .font(AppFonts.sansSerif(size: 13, weight: .light))
                            .foregroundStyle(AppColors.secondary)
                            .padding(.bottom, 40)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 16)
                    }
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        ProductFormTextField(title: "PRODUCT NAME", text: $bindableViewModel.newName)
                        ProductFormTextField(title: "DESCRIPTION", text: $bindableViewModel.newDescription)
                        ProductFormTextField(title: "BRAND", text: $bindableViewModel.newBrand)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            Menu {
                                ForEach(ProductCategory.allCases, id: \.self) { category in
                                    Button(category.rawValue) {
                                        bindableViewModel.newCategory = category
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.newCategory.rawValue)
                                        .font(AppFonts.sansSerif(size: 15))
                                        .foregroundStyle(AppColors.text)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 18)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 1))
                            }
                        }
                        
                        HStack(spacing: 16) {
                            ProductFormTextField(title: "STOCK", text: $bindableViewModel.newAvailableStock, keyboardType: .numberPad)
                            ProductFormTextField(title: "AMOUNT (₹)", text: $bindableViewModel.newAmount, keyboardType: .decimalPad)
                        }
                        
                        if editProduct != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("STATUS")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                Menu {
                                    ForEach([ProductStatus.active, .paused], id: \.self) { status in
                                        Button(status.rawValue) {
                                            bindableViewModel.newStatus = status
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.newStatus.rawValue)
                                            .font(AppFonts.sansSerif(size: 15))
                                            .foregroundStyle(viewModel.newStatus == .active ? AppColors.success : AppColors.gold)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 18)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // Save Button
                    if let product = editProduct {
                        CustomButton(title: "Save Changes", isLoading: viewModel.isSaving) {
                            viewModel.updateProduct(product) {
                                router.pop()
                            }
                        }
                    } else {
                        CustomButton(title: "Scan QR & Save", icon: AnyView(Image(systemName: "qrcode.viewfinder")), isLoading: viewModel.isSaving) {
                            showingScanner = true
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 28)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showingScanner) {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    QRScannerView { code in
                        showingScanner = false
                        bindableViewModel.newBarCode = code
                        viewModel.addProduct {
                            router.pop() // Return to catalogs list after saving
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .navigationTitle("Scan QR")
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if let product = editProduct {
                viewModel.populateForm(with: product)
            } else {
                viewModel.resetForm()
            }
        }
    }
}

private struct ProductFormTextField: View {
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                .foregroundStyle(AppColors.secondary)
                .kerning(1.5)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.tertiary))
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(AppColors.text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.gold15, lineWidth: 1)
                )
        }
    }
}
