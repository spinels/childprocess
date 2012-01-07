module ChildProcess
  module Windows
    FORMAT_MESSAGE_FROM_SYSTEM    = 0x00001000
    FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000

    PROCESS_ALL_ACCESS            = 0x1F0FFF
    PROCESS_QUERY_INFORMATION     = 0x0400
    PROCESS_VM_READ               = 0x0010
    PROCESS_STILL_ACTIVE          = 259

    INFINITE                      = 0xFFFFFFFF

    WIN_SIGINT                    = 2
    WIN_SIGBREAK                  = 3
    WIN_SIGKILL                   = 9

    CTRL_C_EVENT                  = 0
    CTRL_BREAK_EVENT              = 1

    DETACHED_PROCESS              = 0x00000008

    STARTF_USESTDHANDLES          = 0x00000100
    INVALID_HANDLE_VALUE          = 0xFFFFFFFF
    HANDLE_FLAG_INHERIT           = 0x00000001

    DUPLICATE_SAME_ACCESS         = 0x00000002

    CREATE_UNICODE_ENVIRONMENT    = 0x00000400

    module Lib
      enum :wait_status, [
        :wait_object_0,  0,
        :wait_timeout,   0x102,
        :wait_abandoned, 0x80,
        :wait_failed,    0xFFFFFFFF
      ]

      #
      # BOOL WINAPI CreateProcess(
      #   __in_opt     LPCTSTR lpApplicationName,
      #   __inout_opt  LPTSTR lpCommandLine,
      #   __in_opt     LPSECURITY_ATTRIBUTES lpProcessAttributes,
      #   __in_opt     LPSECURITY_ATTRIBUTES lpThreadAttributes,
      #   __in         BOOL bInheritHandles,
      #   __in         DWORD dwCreationFlags,
      #   __in_opt     LPVOID lpEnvironment,
      #   __in_opt     LPCTSTR lpCurrentDirectory,
      #   __in         LPSTARTUPINFO lpStartupInfo,
      #   __out        LPPROCESS_INFORMATION lpProcessInformation
      # );
      #

      attach_function :create_process, :CreateProcessA, [
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :bool,
        :ulong,
        :pointer,
        :pointer,
        :pointer,
        :pointer], :bool

      #
      # DWORD WINAPI GetLastError(void);
      #

      attach_function :get_last_error, :GetLastError, [], :ulong

      #
      #   DWORD WINAPI FormatMessage(
      #   __in      DWORD dwFlags,
      #   __in_opt  LPCVOID lpSource,
      #   __in      DWORD dwMessageId,
      #   __in      DWORD dwLanguageId,
      #   __out     LPTSTR lpBuffer,
      #   __in      DWORD nSize,
      #   __in_opt  va_list *Arguments
      # );
      #

      attach_function :format_message, :FormatMessageA, [
        :ulong,
        :pointer,
        :ulong,
        :ulong,
        :pointer,
        :ulong,
        :pointer], :ulong


      attach_function :close_handle, :CloseHandle, [:pointer], :bool

      #
      # HANDLE WINAPI OpenProcess(
      #   __in  DWORD dwDesiredAccess,
      #   __in  BOOL bInheritHandle,
      #   __in  DWORD dwProcessId
      # );
      #

      attach_function :open_process, :OpenProcess, [:ulong, :bool, :ulong], :pointer

      #
      # DWORD WINAPI WaitForSingleObject(
      #   __in  HANDLE hHandle,
      #   __in  DWORD dwMilliseconds
      # );
      #

      attach_function :wait_for_single_object, :WaitForSingleObject, [:pointer, :ulong], :wait_status

      #
      # BOOL WINAPI GetExitCodeProcess(
      #   __in   HANDLE hProcess,
      #   __out  LPDWORD lpExitCode
      # );
      #

      attach_function :get_exit_code, :GetExitCodeProcess, [:pointer, :pointer], :bool

      #
      # BOOL WINAPI GenerateConsoleCtrlEvent(
      #   __in  DWORD dwCtrlEvent,
      #   __in  DWORD dwProcessGroupId
      # );
      #

      attach_function :generate_console_ctrl_event, :GenerateConsoleCtrlEvent, [:ulong, :ulong], :bool

      #
      # BOOL WINAPI TerminateProcess(
      #   __in  HANDLE hProcess,
      #   __in  UINT uExitCode
      # );
      #

      attach_function :terminate_process, :TerminateProcess, [:pointer, :uint], :bool

      #
      # long _get_osfhandle(
      #    int fd
      # );
      #

      attach_function :get_osfhandle, :_get_osfhandle, [:int], :long

      #
      # int _open_osfhandle (
      #    intptr_t osfhandle,
      #    int flags
      # );
      #

      attach_function :open_osfhandle, :_open_osfhandle, [:pointer, :int], :int

      # BOOL WINAPI SetHandleInformation(
      #   __in  HANDLE hObject,
      #   __in  DWORD dwMask,
      #   __in  DWORD dwFlags
      # );

      attach_function :set_handle_information, :SetHandleInformation, [:long, :ulong, :ulong], :bool

      # BOOL WINAPI GetHandleInformation(
      #   __in   HANDLE hObject,
      #   __out  LPDWORD lpdwFlags
      # );

      attach_function :get_handle_information, :GetHandleInformation, [:long, :pointer], :bool

      # BOOL WINAPI CreatePipe(
      #   __out     PHANDLE hReadPipe,
      #   __out     PHANDLE hWritePipe,
      #   __in_opt  LPSECURITY_ATTRIBUTES lpPipeAttributes,
      #   __in      DWORD nSize
      # );

      attach_function :create_pipe, :CreatePipe, [:pointer, :pointer, :pointer, :ulong], :bool

      #
      # HANDLE WINAPI GetCurrentProcess(void);
      #

      attach_function :current_process, :GetCurrentProcess, [], :pointer

      #
      # BOOL WINAPI DuplicateHandle(
      #   __in   HANDLE hSourceProcessHandle,
      #   __in   HANDLE hSourceHandle,
      #   __in   HANDLE hTargetProcessHandle,
      #   __out  LPHANDLE lpTargetHandle,
      #   __in   DWORD dwDesiredAccess,
      #   __in   BOOL bInheritHandle,
      #   __in   DWORD dwOptions
      # );
      #

      attach_function :_duplicate_handle, :DuplicateHandle, [
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :ulong,
        :bool,
        :ulong
      ], :bool

      class << self
        def kill(signal, *pids)
          case signal
          when 'SIGINT', 'INT', :SIGINT, :INT
            signal = WIN_SIGINT
          when 'SIGBRK', 'BRK', :SIGBREAK, :BRK
            signal = WIN_SIGBREAK
          when 'SIGKILL', 'KILL', :SIGKILL, :KILL
            signal = WIN_SIGKILL
          when 0..9
            # Do nothing
          else
            raise Error, "invalid signal #{signal.inspect}"
          end

          pids.map { |pid| pid if Lib.send_signal(signal, pid) }.compact
        end

        def waitpid(pid, flags = 0)
          wait_for_pid(pid, no_hang?(flags))
        end

        def waitpid2(pid, flags = 0)
          code = wait_for_pid(pid, no_hang?(flags))

          [pid, code] if code
        end

        def dont_inherit(file)
          unless file.respond_to?(:fileno)
            raise ArgumentError, "expected #{file.inspect} to respond to :fileno"
          end

          set_handle_inheritance(handle_for(file.fileno), false)
        end

        def last_error_message
          errnum = get_last_error
          buf = FFI::MemoryPointer.new :char, 512

          size = format_message(
          FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ARGUMENT_ARRAY,
          nil, errnum, 0, buf, buf.size, nil
          )

          str = buf.read_string(size).strip
          "#{str} (#{errnum})"
        end

        def handle_for(fd_or_io)
          case fd_or_io
          when IO
            handle = get_osfhandle(fd_or_io.fileno)
          when Fixnum
            handle = get_osfhandle(fd_or_io)
          else
            if fd_or_io.respond_to?(:to_io)
              io = fd_or_io.to_io

              unless io.kind_of?(IO)
                raise TypeError, "expected #to_io to return an instance of IO"
              end

              handle = get_osfhandle(io.fileno)
            else
              raise TypeError, "invalid type: #{fd_or_io.inspect}"
            end
          end

          if handle == INVALID_HANDLE_VALUE
            raise Error, last_error_message
          end

          handle
        end

        def io_for(handle, flags = File::RDONLY)
          fd = open_osfhandle(handle, flags)
          if fd == -1
            raise Error, last_error_message
          end

          ::IO.for_fd fd, flags
        end

        def duplicate_handle(handle)
          dup  = FFI::MemoryPointer.new(:pointer)
          proc = current_process

          ok = Lib._duplicate_handle(
            proc,
            handle,
            proc,
            dup,
            0,
            false,
            DUPLICATE_SAME_ACCESS
          )

          check_error ok

          dup.read_pointer
        ensure
          close_handle proc
        end

        def set_handle_inheritance(handle, bool)
          status = set_handle_information(
            handle,
            HANDLE_FLAG_INHERIT,
            bool ? HANDLE_FLAG_INHERIT : 0
          )

          check_error status
        end

        def get_handle_inheritance(handle)
          flags = FFI::MemoryPointer.new(:uint)

          status = get_handle_information(
            handle,
            flags
          )

          check_error status

          flags.read_uint
        end

        def check_error(bool)
          bool or raise Error, last_error_message
        end

        def no_hang?(flags)
          (flags & Process::WNOHANG) == Process::WNOHANG
        end

        def wait_for_pid(pid, no_hang)
          code = Handle.open(pid) { |handle|
            handle.wait unless no_hang
            handle.exit_code
          }

          code if code != PROCESS_STILL_ACTIVE
        end
      end

    end # Lib
  end # Windows
end # ChildProcess