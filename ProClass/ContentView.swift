import SwiftUI
import PhotosUI

struct WaveAnimation: View {
    @State private var phase = 0.0
    let strength: Double
    let frequency: Double
    let color: Color
    
    init(strength: Double = 50, frequency: Double = 1, color: Color = .blue) {
        self.strength = strength
        self.frequency = frequency
        self.color = color
    }
    
    private func calculateWaveY(at relativeX: Double, baseOffset: Double) -> Double {
        let wave1 = sin((relativeX * 360 + baseOffset) * .pi / 180) * 0.5
        let wave2 = sin((relativeX * 180 + baseOffset * 0.5) * .pi / 180) * 0.3
        return (wave1 + wave2) * strength
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeNow = timeline.date.timeIntervalSinceReferenceDate
                let angle = timeNow.remainder(dividingBy: 8)
                let baseOffset = angle * frequency * 100
                
                context.translateBy(x: 0, y: size.height * 0.5)
                
                let path = Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    
                    for x in stride(from: 0, through: size.width, by: 1) {
                        let relativeX = x / size.width
                        let y = calculateWaveY(at: relativeX, baseOffset: baseOffset)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                }
                
                context.fill(path, with: .linearGradient(
                    Gradient(colors: [
                        color.opacity(0.5),
                        color.opacity(0.3),
                        color.opacity(0.1)
                    ]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: size.height)
                ))
            }
        }
        .ignoresSafeArea()
    }
}

struct GlassCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let professor: String
    let icon: String
    let gradient: [Color]
}

struct AnimatedButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            Image(systemName: systemName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .scaleEffect(1)
        .shadow(radius: 10)
    }
}

struct MenuCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(GlassCard())
        }
    }
}

struct DetailCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isPresented: Bool
    let content: AnyView
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            VStack(spacing: 20) {
                content
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(GlassCard())
            }
            .padding()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(color)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding()
                }
            }
        }
    }
}

struct FloatingMenu: View {
    @Binding var isExpanded: Bool
    @State private var showingVikingsCash = false
    @State private var showingEmergency = false
    @State private var showingLoanDue = false
    @State private var showingEvents = false
    @State private var buttonBlur: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                if isExpanded {
                    VStack(spacing: 10) {
                        MenuCard(title: "Vikings Cash", icon: "creditcard.fill", color: .green) {
                            showingVikingsCash.toggle()
                        }
                        MenuCard(title: "Emergency", icon: "exclamationmark.triangle.fill", color: .red) {
                            showingEmergency.toggle()
                        }
                        MenuCard(title: "Loan Due", icon: "dollarsign.circle.fill", color: .orange) {
                            showingLoanDue.toggle()
                        }
                        MenuCard(title: "Events", icon: "calendar.badge.clock", color: .blue) {
                            showingEvents.toggle()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
            .background(
                isExpanded ? RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .background(.black.opacity(0.7))
                    .blur(radius: 1)
                    : nil
            )
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            buttonBlur = 5
                            isExpanded.toggle()
                        }
                        
                        // Reset the blur after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                buttonBlur = 0
                            }
                        }
                        
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        Image(systemName: isExpanded ? "xmark.circle.fill" : "ellipsis.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                            .blur(radius: buttonBlur)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: buttonBlur)
                    }
                    .padding()
                }
            }
            
            if showingVikingsCash {
                DetailCard(title: "Vikings Cash", icon: "creditcard.fill", color: .green, isPresented: $showingVikingsCash, content: AnyView(
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Vikings Cash Balance")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("$245.50")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                        
                        Divider().background(.white.opacity(0.2))
                        
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        ForEach(["Dining Hall - $12.50", "Campus Store - $25.00", "Printing - $2.00"], id: \.self) { transaction in
                            Text(transaction)
                                .foregroundColor(.white)
                        }
                    }
                ))
            }
            
            if showingEmergency {
                DetailCard(title: "Emergency", icon: "exclamationmark.triangle.fill", color: .red, isPresented: $showingEmergency, content: AnyView(
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Emergency Contacts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ForEach(["Campus Security: 911", "Health Services: (555) 123-4567", "Counseling: (555) 987-6543"], id: \.self) { contact in
                            Text(contact)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Text("Call Emergency Services")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(GlassCard())
                                .cornerRadius(15)
                        }
                    }
                ))
            }
            
            if showingLoanDue {
                DetailCard(title: "Loan Due", icon: "dollarsign.circle.fill", color: .orange, isPresented: $showingLoanDue, content: AnyView(
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Student Loan Status")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Next Payment Due")
                            .foregroundColor(.white.opacity(0.7))
                        Text("September 15, 2024")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Amount Due")
                            .foregroundColor(.white.opacity(0.7))
                        Text("$1,250.00")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.orange)
                    }
                ))
            }
            
            if showingEvents {
                DetailCard(title: "Events", icon: "calendar.badge.clock", color: .blue, isPresented: $showingEvents, content: AnyView(
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Events")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ForEach(["Career Fair - Sep 20", "Alumni Meet - Sep 25", "Tech Symposium - Oct 5"], id: \.self) { event in
                            HStack {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 8, height: 8)
                                Text(event)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                ))
            }
        }
    }
}

struct CourseCard: View {
    let course: Course
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: CourseDetailView(course: course)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: course.icon)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                        Text(course.professor)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    GlassCard()
                    LinearGradient(colors: course.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .opacity(0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: course.gradient[0].opacity(0.3), radius: 15, x: 0, y: 10)
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(TapGesture().onEnded {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        })
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ActivityCard: View {
    let activities: [CourseActivity]
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                    Text("Activity")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.white)
                .padding()
                .background(GlassCard())
            }
            
            if isExpanded {
                VStack(spacing: 15) {
                    ForEach(activities) { activity in
                        HStack {
                            Circle()
                                .fill(activity.type.color)
                                .frame(width: 10, height: 10)
                            Text(activity.title)
                                .foregroundColor(.white)
                            Spacer()
                            Text(activity.date)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct GradeCard: View {
    let grades: [CourseGrade]
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                    Text("Grades")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.white)
                .padding()
                .background(GlassCard())
            }
            
            if isExpanded {
                VStack(spacing: 15) {
                    ForEach(grades) { grade in
                        HStack {
                            Text(grade.title)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(grade.score, specifier: "%.1f")%")
                                .foregroundColor(grade.score >= 90 ? .green : .white)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct ContentCard: View {
    let contents: [CourseContent]
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "doc.fill")
                        .font(.title2)
                    Text("Content")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.white)
                .padding()
                .background(GlassCard())
            }
            
            if isExpanded {
                VStack(spacing: 15) {
                    ForEach(contents) { content in
                        HStack {
                            Image(systemName: content.type.icon)
                                .foregroundColor(content.type.color)
                            Text(content.title)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct DueDateView: View {
    let assignments: [Assignment]
    @State private var showingDueDates = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showingDueDates.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(GlassCard())
                    .overlay(
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 10, y: -10)
                    )
            }
            
            if showingDueDates {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Due Dates")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(assignments.filter { $0.isWithinFourWeeks }) { assignment in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(assignment.title)
                                    .foregroundColor(.white)
                                Text(assignment.dueDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Circle()
                                .fill(assignment.isUrgent ? .red : .orange)
                                .frame(width: 8, height: 8)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(GlassCard())
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct CourseDetailView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @State private var opacity = 0.0
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: course.icon)
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(colors: course.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    
                    Spacer()
                    
                    DueDateView(assignments: course.assignments)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                
                Text(course.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    ActivityCard(activities: course.activities)
                    GradeCard(grades: course.grades)
                    ContentCard(contents: course.contents)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.black)
        .opacity(opacity)
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if value.translation.width > 0 {
                        state = value.translation
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dismiss()
                        }
                    }
                }
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
        }
    }
}

struct ContentView: View {
    let courses = [
        Course(title: "Machine Learning", professor: "Dr. Sarah Johnson", icon: "brain.head.profile", gradient: [.green, Color(red: 0.2, green: 0.8, blue: 0.4)]),
        Course(title: "Design Thinking", professor: "Prof. Michael Chen", icon: "ruler.fill", gradient: [Color(red: 0.1, green: 0.6, blue: 0.3), .green]),
        Course(title: "Business Intelligence", professor: "Dr. Emily Rodriguez", icon: "chart.bar.fill", gradient: [.green, Color(red: 0.2, green: 0.7, blue: 0.4)])
    ]
    
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CourseListView(courses: courses)
                .tabItem {
                    Label("Info Science", systemImage: "book.fill")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .onChange(of: selectedTab) { _, newValue in
            if previousTab != newValue {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                previousTab = newValue
            }
        }
        .tint(.green)
        .preferredColorScheme(.dark)
    }
}

struct CourseListView: View {
    let courses: [Course]
    @State private var searchText = ""
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Simplified wave configuration
                ZStack {
                    WaveAnimation(strength: 120, frequency: 0.4, color: .green)
                        .offset(y: 50)
                    WaveAnimation(strength: 100, frequency: 0.3, color: Color(red: 0.2, green: 0.8, blue: 0.4))
                        .offset(y: 150)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Information\nScience")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(Array(courses.enumerated()), id: \.element.id) { index, course in
                            CourseCard(course: course)
                                .padding(.horizontal)
                                .offset(y: appearAnimation ? 0 : 50)
                                .opacity(appearAnimation ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                    value: appearAnimation
                                )
                        }
                    }
                    .padding(.vertical)
                }
            }
            .onAppear {
                appearAnimation = true
            }
        }
    }
}

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    @State private var photosPickerItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $photosPickerItem,
                    matching: .images) {
            Label("Choose Photo", systemImage: "photo.fill")
                .foregroundColor(.white)
                .padding()
                .background(GlassCard())
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    imageData = image.jpegData(compressionQuality: 1.0)
                    dismiss()
                }
            }
        }
    }
}

struct ProfileImageView: View {
    @Binding var profileImage: UIImage?
    @Binding var profileImageData: Data?
    @State private var showingImagePicker = false
    @State private var isLongPressed = false
    
    var body: some View {
        ZStack {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 4))
        .shadow(radius: 10)
        .scaleEffect(isLongPressed ? 0.9 : 1.0)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
                .presentationBackground(.clear)
                .presentationDetents([.height(100)])
        }
        .onLongPressGesture(minimumDuration: 0.5) { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isLongPressed = pressing
            }
        } perform: {
            showingImagePicker = true
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

struct NameEditor: View {
    @Binding var name: String
    @Environment(\.dismiss) private var dismiss
    @State private var editedName: String
    @FocusState private var isNameFocused: Bool
    
    init(name: Binding<String>) {
        self._name = name
        self._editedName = State(initialValue: name.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Name")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Enter your name", text: $editedName)
                .textFieldStyle(.plain)
                .padding()
                .background(GlassCard())
                .foregroundColor(.white)
                .focused($isNameFocused)
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.7))
                
                Button("Save") {
                    name = editedName
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.green)
            }
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
        .onAppear {
            isNameFocused = true
        }
    }
}

struct ProfileNameView: View {
    @Binding var name: String
    @State private var showingNameEditor = false
    @State private var isLongPressed = false
    
    var body: some View {
        Text(name)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .scaleEffect(isLongPressed ? 0.9 : 1.0)
            .sheet(isPresented: $showingNameEditor) {
                NameEditor(name: $name)
                    .presentationBackground(.clear)
                    .presentationDetents([.height(250)])
            }
            .onLongPressGesture(minimumDuration: 0.5) { pressing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLongPressed = pressing
                }
            } perform: {
                showingNameEditor = true
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
    }
}

struct ProfileView: View {
    private let workSessionTime = 25 * 60  // 25 minutes in seconds
    private let restSessionTime = 5 * 60   // 5 minutes in seconds
    
    @State private var timerValue = 25 * 60  // Start with work session
    @State private var isTimerRunning = false
    @State private var completedSessions = 0
    @State private var timer: Timer?
    @State private var isRestSession = false
    @AppStorage("profileImage") private var profileImageData: Data?
    @AppStorage("userName") private var userName: String = "Puja Santosh"
    @State private var profileImage: UIImage?
    @State private var isMenuExpanded = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Using same wave configuration as CourseListView
            ZStack {
                WaveAnimation(strength: 120, frequency: 0.4, color: .green)
                    .offset(y: 50)
                WaveAnimation(strength: 100, frequency: 0.3, color: Color(red: 0.2, green: 0.8, blue: 0.4))
                    .offset(y: 150)
            }
            
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    ProfileImageView(profileImage: $profileImage, profileImageData: $profileImageData)
                    ProfileNameView(name: $userName)
                }
                .padding(.top, 30)
                
                VStack(spacing: 20) {
                    Text(isRestSession ? "Rest Session" : "Work Session")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(timeString(from: timerValue))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(isRestSession ? .green : .white)
                    
                    HStack(spacing: 30) {
                        AnimatedButton(systemName: "arrow.counterclockwise") {
                            resetTimer()
                        }
                        
                        AnimatedButton(systemName: isTimerRunning ? "pause.fill" : "play.fill") {
                            toggleTimer()
                        }
                        
                        AnimatedButton(systemName: "forward.fill") {
                            skipSession()
                        }
                    }
                }
                .padding(30)
                .background(GlassCard())
                .shadow(radius: 20)
                
                VStack(spacing: 10) {
                    Text("Completed Sessions")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(completedSessions)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(GlassCard())
                .shadow(radius: 20)
                
                Spacer()
            }
            .padding()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingMenu(isExpanded: $isMenuExpanded)
                }
            }
        }
        .onAppear {
            loadProfileImage()
        }
    }
    
    private func loadProfileImage() {
        if let imageData = profileImageData,
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timerValue > 0 {
                    timerValue -= 1
                } else {
                    if isRestSession {
                        completeSession()
                    } else {
                        startRestSession()
                    }
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        isRestSession = false
        timerValue = workSessionTime
    }
    
    private func skipSession() {
        if isRestSession {
            completeSession()
        } else {
            startRestSession()
        }
    }
    
    private func startRestSession() {
        isRestSession = true
        timerValue = restSessionTime
        // Add haptic feedback for session change
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func completeSession() {
        completedSessions += 1
        isRestSession = false
        timerValue = workSessionTime
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        // Add haptic feedback for completion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ContentView()
}

// Model extensions
extension Course {
    var activities: [CourseActivity] {
        [
            CourseActivity(title: "Watched ML Basics", date: "Today", type: .video),
            CourseActivity(title: "Completed Quiz 1", date: "Yesterday", type: .quiz),
            CourseActivity(title: "Submitted Assignment", date: "2 days ago", type: .assignment)
        ]
    }
    
    var grades: [CourseGrade] {
        [
            CourseGrade(title: "Assignment 1", score: 95.0),
            CourseGrade(title: "Quiz 1", score: 88.5),
            CourseGrade(title: "Midterm", score: 92.0)
        ]
    }
    
    var contents: [CourseContent] {
        [
            CourseContent(title: "Course Introduction", type: .pdf),
            CourseContent(title: "Week 1 Lecture", type: .video),
            CourseContent(title: "Practice Problems", type: .document)
        ]
    }
    
    var assignments: [Assignment] {
        [
            Assignment(title: "Project Proposal", dueDate: Date().addingTimeInterval(3 * 24 * 3600)),
            Assignment(title: "Quiz 2", dueDate: Date().addingTimeInterval(7 * 24 * 3600)),
            Assignment(title: "Final Project", dueDate: Date().addingTimeInterval(20 * 24 * 3600))
        ]
    }
}

// Supporting Models
struct CourseActivity: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let type: ActivityType
    
    enum ActivityType {
        case video, quiz, assignment
        
        var color: Color {
            switch self {
            case .video: return .blue
            case .quiz: return .orange
            case .assignment: return .green
            }
        }
    }
}

struct CourseGrade: Identifiable {
    let id = UUID()
    let title: String
    let score: Double
}

struct CourseContent: Identifiable {
    let id = UUID()
    let title: String
    let type: ContentType
    
    enum ContentType {
        case pdf, video, document
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .video: return "play.circle.fill"
            case .document: return "doc.text.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pdf: return .red
            case .video: return .blue
            case .document: return .orange
            }
        }
    }
}

struct Assignment: Identifiable {
    let id = UUID()
    let title: String
    let dueDate: Date
    
    var isWithinFourWeeks: Bool {
        let fourWeeks = Date().addingTimeInterval(4 * 7 * 24 * 3600)
        return dueDate <= fourWeeks
    }
    
    var isUrgent: Bool {
        let oneWeek = Date().addingTimeInterval(7 * 24 * 3600)
        return dueDate <= oneWeek
    }
}
