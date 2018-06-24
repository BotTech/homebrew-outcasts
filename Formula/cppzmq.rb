class Cppzmq < Formula
  desc "Header-only C++ binding for libzmq"
  homepage "http://www.zeromq.org"
  url "https://github.com/zeromq/cppzmq/archive/v4.2.3.tar.gz"
  sha256 "3e6b57bf49115f4ae893b1ff7848ead7267013087dc7be1ab27636a97144d373"

  depends_on "cmake" => :build
  depends_on "zeromq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "-j4", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <zmq.hpp>
      #include <iostream>
      int main()
      {
        int major=0, minor=0, patch=0;
        zmq::version(&major, &minor, &patch);
        std::cout << major << "." << minor << "." << patch << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-lzmq", "-o", "test"
  end
end
